import { later, cancel } from "@ember/runloop";
import { apiInitializer } from "discourse/lib/api";
import { ajax } from "discourse/lib/ajax";

// -------------------------------------------------------
// discourse-topic-hover-cards
// Shows a rich topic card as a hover tooltip whenever a
// user mouses over any internal topic link inside a post
// or reply body.  Works on .cooked links, suggested topics,
// timeline jump links, etc.
//
// On mobile (touch devices) the card opens on tap when
// enable_on_mobile is true, and a second tap navigates.
// -------------------------------------------------------

const DELAY_SHOW     = settings.card_delay_ms ?? 300;
const DELAY_HIDE     = 200;
const CARD_WIDTH     = settings.card_width ?? 420;
const CARD_MAX_H     = settings.card_max_height ?? 480;
const MOBILE_ENABLED = settings.enable_on_mobile ?? false;
const VIEWPORT_MARGIN = 12;

// Matches /t/some-slug/123 or /t/123  (with optional /post-number)
const TOPIC_LINK_RE = /\/t\/(?:[^/]+\/)?([0-9]+)(?:\/[0-9]+)?/;

/** Detect touch-only (mobile/tablet) device */
function isTouchDevice() {
  return window.matchMedia("(hover: none) and (pointer: coarse)").matches;
}

/** Extract a numeric topic id from an href, or null */
function topicIdFromHref(href) {
  if (!href) return null;
  try {
    const url = new URL(href, window.location.origin);
    if (url.origin !== window.location.origin) return null;
    const m = url.pathname.match(TOPIC_LINK_RE);
    return m ? parseInt(m[1], 10) : null;
  } catch {
    return null;
  }
}

/** Format a compact number */
function fmtNum(n) {
  if (!n && n !== 0) return "0";
  if (n >= 1000) return (n / 1000).toFixed(1).replace(/\.0$/, "") + "k";
  return String(n);
}

/** Strip HTML to plain text */
function stripHtml(html) {
  if (!html) return "";
  const t = document.createElement("div");
  t.innerHTML = html;
  return t.textContent || t.innerText || "";
}

/** Skeleton markup shown while API loads */
function skeletonHTML() {
  return `
    <div class="topic-hover-card__skeleton">
      <div class="skeleton-line title"></div>
      <div class="skeleton-line title-2"></div>
      <div class="skeleton-line excerpt"></div>
      <div class="skeleton-line excerpt-2"></div>
      <div class="skeleton-line excerpt-3"></div>
      <div class="skeleton-line meta"></div>
    </div>`;
}

/** Minimal inline SVG icons (no dependency on Discourse sprite) */
function dIconSVG(name) {
  const paths = {
    eye:     "M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z",
    comment: "M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z",
    heart:   "M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z",
    clock:   "M12 2a10 10 0 1 0 0 20A10 10 0 0 0 12 2zm0 18a8 8 0 1 1 0-16 8 8 0 0 1 0 16zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z",
  };
  const d = paths[name] ?? "";
  return `<svg class="d-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="${d}"/></svg>`;
}

/** Build the full card HTML from a topic JSON payload */
function buildCardHTML(topic) {
  // Thumbnail
  const thumbnail = topic.image_url && settings.show_thumbnail
    ? `<div class="topic-hover-card__thumbnail">
         <img src="${topic.image_url}" alt="" loading="lazy">
       </div>`
    : "";

  // Category badge
  let categoryHTML = "";
  if (topic.category_id) {
    const name  = topic.category_name ?? topic.category_slug ?? "";
    const color = topic.category_color ? `#${topic.category_color}` : "var(--primary-medium)";
    categoryHTML = `<div class="topic-hover-card__category">
      <span class="badge-category" style="--category-badge-color:${color}">${name}</span>
    </div>`;
  }

  const title = topic.fancy_title ?? topic.title ?? "(no title)";

  // Excerpt
  const excerpt = settings.show_excerpt && topic.excerpt
    ? `<div class="topic-hover-card__excerpt">${stripHtml(topic.excerpt)}</div>`
    : "";

  // OP / author (controlled by show_op setting)
  let opHTML = "";
  if (settings.show_op) {
    const op = topic.details?.created_by ?? topic.posters?.[0]?.user;
    if (op) {
      const avatarTemplate = op.avatar_template?.replace("{size}", "24");
      const avatarURL = avatarTemplate
        ? (avatarTemplate.startsWith("http") ? avatarTemplate : window.location.origin + avatarTemplate)
        : null;
      const avatarImg = avatarURL
        ? `<img src="${avatarURL}" width="24" height="24" alt="" loading="lazy">`
        : "";
      opHTML = `<div class="topic-hover-card__op">${avatarImg}<span class="username">${op.username}</span></div>`;
    }
  }

  // Stats
  const statItems = [];
  if (settings.show_views) {
    statItems.push(`<span class="topic-hover-card__stat">${dIconSVG("eye")} ${fmtNum(topic.views)}</span>`);
  }
  if (settings.show_reply_count) {
    statItems.push(`<span class="topic-hover-card__stat">${dIconSVG("comment")} ${fmtNum(topic.reply_count ?? (topic.posts_count - 1))}</span>`);
  }
  if (settings.show_likes) {
    const likes = topic.like_count ?? topic.topic_post_like_count ?? 0;
    statItems.push(`<span class="topic-hover-card__stat">${dIconSVG("heart")} ${fmtNum(likes)}</span>`);
  }
  if (settings.show_activity && topic.last_posted_at) {
    const d = new Date(topic.last_posted_at);
    const fmt = d.toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
    statItems.push(`<span class="topic-hover-card__stat">${dIconSVG("clock")} ${fmt}</span>`);
  }

  const statsHTML = statItems.length
    ? `<div class="topic-hover-card__stats">${statItems.join("")}</div>`
    : "";

  // Publish date
  let publishDate = "";
  if (settings.show_publish_date && topic.created_at) {
    const d = new Date(topic.created_at);
    const fmt = d.toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
    publishDate = `<span class="topic-hover-card__publish-date">${fmt}</span>`;
  }

  const metadata = (publishDate || statsHTML)
    ? `<div class="topic-hover-card__metadata">${publishDate}${statsHTML}</div>`
    : "";

  return `
    ${thumbnail}
    <div class="topic-hover-card__body">
      ${categoryHTML}
      <div class="topic-hover-card__title">${title}</div>
      ${excerpt}
      ${opHTML}
      ${metadata}
    </div>`;
}

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");

  // ---- Guard: skip entirely if mobile is disabled ----
  // isTouchDevice() is evaluated at runtime so desktop users who happen to
  // have a touch screen still get hover behaviour.
  const onMobile = site.mobileView || isTouchDevice();
  if (onMobile && !MOBILE_ENABLED) return;

  // ---- State ----
  let tooltip        = null;
  let showTimer      = null;
  let hideTimer      = null;
  let currentTopicId = null;
  let topicCache     = {};
  let isInsideCard   = false;
  // Mobile tap state: track the link that was last tapped
  let mobileTappedLink = null;

  // ---- Build / mount tooltip DOM node once ----
  function ensureTooltip() {
    if (tooltip) return;
    tooltip = document.createElement("div");
    tooltip.className = "topic-hover-card-tooltip";
    tooltip.setAttribute("role", "tooltip");
    tooltip.setAttribute("aria-live", "polite");
    tooltip.style.setProperty("--thc-width",  CARD_WIDTH  + "px");
    tooltip.style.setProperty("--thc-max-h",  CARD_MAX_H  + "px");

    const card = document.createElement("div");
    card.className = "topic-hover-card";
    tooltip.appendChild(card);

    tooltip.addEventListener("mouseenter", () => {
      isInsideCard = true;
      cancel(hideTimer);
    });
    tooltip.addEventListener("mouseleave", () => {
      isInsideCard = false;
      scheduleHide();
    });

    document.body.appendChild(tooltip);
  }

  function cardEl() {
    return tooltip?.querySelector(".topic-hover-card");
  }

  // ---- Positioning ----
  function positionTooltip(anchorRect) {
    if (!tooltip) return;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const cardH = Math.min(tooltip.offsetHeight || 320, CARD_MAX_H);
    const cardW = Math.min(CARD_WIDTH, vw - VIEWPORT_MARGIN * 2);

    let top = anchorRect.bottom + 10;
    let isAbove = false;
    if (top + cardH > vh - VIEWPORT_MARGIN) {
      top = anchorRect.top - cardH - 10;
      isAbove = true;
    }
    top = Math.max(VIEWPORT_MARGIN, top);

    let left = anchorRect.left;
    if (left + cardW > vw - VIEWPORT_MARGIN) left = vw - cardW - VIEWPORT_MARGIN;
    left = Math.max(VIEWPORT_MARGIN, left);

    tooltip.style.top  = top  + "px";
    tooltip.style.left = left + "px";
    tooltip.classList.toggle("is-above", isAbove);
  }

  // ---- Show / hide ----
  function showCard(topicId, anchorRect) {
    ensureTooltip();
    cancel(hideTimer);

    if (currentTopicId === topicId && tooltip.classList.contains("is-visible")) {
      positionTooltip(anchorRect);
      return;
    }

    currentTopicId = topicId;
    const card = cardEl();

    if (topicCache[topicId]) {
      card.innerHTML = buildCardHTML(topicCache[topicId]);
    } else {
      card.innerHTML = skeletonHTML();
      fetchTopic(topicId)
        .then((data) => {
          if (currentTopicId === topicId) {
            card.innerHTML = buildCardHTML(data);
            positionTooltip(anchorRect);
          }
        })
        .catch(() => {
          if (currentTopicId === topicId) {
            card.innerHTML = `<div class="topic-hover-card__loading">Could not load topic.</div>`;
          }
        });
    }

    positionTooltip(anchorRect);
    tooltip.classList.add("is-visible");
  }

  function hideCard() {
    if (!tooltip) return;
    tooltip.classList.remove("is-visible");
    later(() => { if (!tooltip.classList.contains("is-visible")) currentTopicId = null; }, 400);
  }

  function scheduleShow(topicId, anchorRect) {
    cancel(showTimer);
    cancel(hideTimer);
    showTimer = later(() => showCard(topicId, anchorRect), DELAY_SHOW);
  }

  function scheduleHide() {
    cancel(hideTimer);
    hideTimer = later(() => { if (!isInsideCard) hideCard(); }, DELAY_HIDE);
  }

  // ---- API fetch ----
  async function fetchTopic(topicId) {
    if (topicCache[topicId]) return topicCache[topicId];
    const data = await ajax(`/t/${topicId}.json`);
    topicCache[topicId] = data;
    return data;
  }

  // ---- Hover listeners (desktop) ----
  function onMouseEnter(event) {
    if (onMobile) return; // handled by touch path
    const link = event.target.closest("a[href]");
    if (!link) return;
    const inContent = link.closest(
      ".cooked, .topic-body, .topic-list, .suggested-topics, .timeline-container, .topic-map"
    );
    if (!inContent) return;
    const topicId = topicIdFromHref(link.href);
    if (!topicId) return;
    scheduleShow(topicId, link.getBoundingClientRect());
  }

  function onMouseLeave(event) {
    if (onMobile) return;
    const link = event.target.closest("a[href]");
    if (!link || !topicIdFromHref(link.href)) return;
    scheduleHide();
  }

  // ---- Touch listener (mobile, when enabled) ----
  // First tap: open card (preventDefault stops navigation).
  // Second tap on the SAME link: allow navigation to proceed normally.
  // Tap anywhere else: dismiss card.
  function onTouchEnd(event) {
    if (!onMobile || !MOBILE_ENABLED) return;
    const link = event.target.closest("a[href]");

    // Tap outside any link → dismiss
    if (!link) {
      if (tooltip?.classList.contains("is-visible")) {
        hideCard();
        mobileTappedLink = null;
      }
      return;
    }

    const inContent = link.closest(
      ".cooked, .topic-body, .topic-list, .suggested-topics, .timeline-container, .topic-map"
    );
    if (!inContent) return;

    const topicId = topicIdFromHref(link.href);
    if (!topicId) return;

    // Second tap on already-previewed link → let navigation happen
    if (mobileTappedLink === link && tooltip?.classList.contains("is-visible")) {
      hideCard();
      mobileTappedLink = null;
      return; // don't prevent default
    }

    // First tap → show card, block navigation
    event.preventDefault();
    mobileTappedLink = link;
    showCard(topicId, link.getBoundingClientRect());
  }

  document.addEventListener("mouseover", onMouseEnter, { passive: true });
  document.addEventListener("mouseout",  onMouseLeave, { passive: true });
  document.addEventListener("touchend",  onTouchEnd,   { passive: false });

  // Dismiss on scroll
  document.addEventListener("scroll", () => {
    cancel(showTimer);
    hideCard();
    mobileTappedLink = null;
  }, { passive: true, capture: true });

  // Clean up on page change (Ember router)
  api.onPageChange(() => {
    cancel(showTimer);
    cancel(hideTimer);
    hideCard();
    currentTopicId = null;
    mobileTappedLink = null;
  });
});
