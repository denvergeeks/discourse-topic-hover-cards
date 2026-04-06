# Discourse Topic Hover Cards

A Discourse theme component that shows rich hover preview cards for **internal topic links** across topics, replies, topic lists, the categories homepage, Doc Categories, Kanban boards, and suggested topics.

When users hover a topic link (or tap on mobile), a card appears with the topic thumbnail, title, excerpt, category, tags, and key stats.

---

## Features

- Hover cards for internal topic links in:
  - Topic body (original post)
  - Replies
  - Standard topic lists (`/latest`, `/top`, `/tags`, category topic lists, etc.)
  - Categories homepage topic lists (Categories + Latest, Categories-only, and related layouts)
  - Doc Categories views
  - Kanban-style board views
  - Suggested topics
- Responsive layout:
  - Desktop card with configurable density and thumbnail placement
  - Mobile bottom-sheet preview with tap-to-open
- Configurable content:
  - Thumbnail image
  - Category badge
  - Tags
  - Title
  - Excerpt (cleaned of images/lightboxes)
  - Original poster
  - Publish date
  - Views, replies, likes, last activity
- Per-user opt-out using a custom user field
- Admin-only debug mode for safe troubleshooting

---

## Installation

1. Go to **Admin → Customize → Themes → Components**.
2. Click **Install** and add the git repository URL for this component.
3. Once installed, add the component to the themes you want it active on.
4. (Optional) Make the theme user-selectable while testing, so only you see changes. [web:580]

For theme/component structure and git-based installs, see **Structure of themes and theme components** in the Discourse developer docs. [web:409]

---

## Settings

All settings are under **Admin → Customize → Themes → [this component] → Settings**. [web:22]

### Layout & timing

- **card_width**  
  Any CSS width value (for desktop), e.g. `32rem`, `420px`, `40vw`, `clamp(20rem, 40vw, 36rem)`.

- **card_max_height**  
  Any CSS max-height value, e.g. `10rem`, `480px`, `50vh`, `min(60vh, 32rem)`.

- **card_delay_ms**  
  Delay before showing the hover card, in milliseconds (default: `300`).

- **enable_on_mobile**  
  When enabled, tap on a supported internal topic link shows a mobile preview sheet.

- **mobile_width_percent**  
  Width of the mobile bottom-sheet preview as a percentage of viewport width (default: `100`).

- **mobile_thumbnail_height**  
  Thumbnail height in pixels for the mobile preview.

### Density

- **density**  
  Desktop density: `default`, `cozy`, or `compact`.

- **density_mobile**  
  Mobile density: `default`, `cozy`, or `compact`.

These are parallel to the Discourse “Density” patterns and simply adjust padding and line heights.

### Thumbnail & placement

- **show_thumbnail** / **show_thumbnail_mobile**  
  Show/hide the topic image (if any) on desktop and mobile.

- **thumbnail_placement**  
  How the thumbnail is positioned on desktop:
  - `top`
  - `left`
  - `right`
  - `bottom`  
  On mobile, the thumbnail is always rendered at the top of the card.

- **image_size_percent**  
  For desktop `left` and `right` layouts, controls thumbnail width as a percentage of the hover card width.

### Fields per viewport

For each block below, you have both desktop and mobile toggles:

- **show_category** / **show_category_mobile**
- **show_tags** / **show_tags_mobile**
- **show_title** / **show_title_mobile**
- **show_excerpt** / **show_excerpt_mobile**
- **excerpt_length** / **excerpt_length_mobile**  
  Number of lines for the excerpt (CSS line-clamp).

- **show_op** / **show_op_mobile**  
  Shows original poster avatar + username.

- **show_publish_date** / **show_publish_date_mobile**
- **show_views** / **show_views_mobile**
- **show_reply_count** / **show_reply_count_mobile**
- **show_likes** / **show_likes_mobile**
- **show_activity** / **show_activity_mobile**

### Where hover cards appear

- **enable_on_topics**  
  Topic links in the original post.

- **enable_on_replies**  
  Topic links in replies.

- **enable_on_topic_lists**  
  Topic links in standard topic lists, e.g. `/latest`, `/top`, category topic lists.

- **enable_on_category_homepage_topic_lists**  
  Topic links in the “latest topics” or equivalent lists on the **categories homepage**:
  - Categories + Latest Topics
  - Categories-only
  - Related variants rendered at `/` or `/categories`, depending on how your homepage is configured. [web:807][web:922]

- **enable_on_doc_categories**  
  Topic links in **Doc Categories** views (when applicable).

- **enable_on_kanban_boards**  
  Topic links rendered in Kanban-style board layouts (when applicable).

- **enable_on_suggested_topic_links**  
  Links in the “Suggested topics” section.

---

## Per-user opt-out

You can let individual users disable hover cards using a **custom user field**. This uses the standard theme-settings mechanism and current-user data access described in the developer guides. [web:22][web:876]

- **user_preference_field_name**  
  The key used to detect opt-out on the current user. This can be:
  - a direct custom field key, e.g. `disable_topic_hover_cards`
  - a numeric ID, e.g. `1`
  - a `user_field_X` key, e.g. `user_field_1`

### How matching works

1. The component first checks the current user’s `custom_fields` and `user_fields` for:
   - the configured `user_preference_field_name`
   - the same value converted between `1` and `user_field_1` when appropriate
2. If no match is found and the current user is staff (admin/moderator) and
   **resolve_user_field_id_for_admins** is enabled, the component calls:
   - `/admin/config/user-fields.json`  
     to map the configured value (field name or `user_field_X`) to its numeric ID.
3. With the numeric ID, it checks:
   - `user_fields[id]`
   - `user_fields['user_field_' + id]`
   - `custom_fields[id]`
   - `custom_fields['user_field_' + id]`

Any truthy value in those positions (e.g. `1`, `true`, `yes`, `on`, `checked`) disables hover cards for that user.

### Settings for this behavior

- **resolve_user_field_id_for_admins**  
  When enabled (recommended), admins can configure the field either by name or `user_field_X`, and the component will resolve and match the numeric ID automatically.

- **debug_mode**  
  When enabled, logs detailed detection information to the browser console for staff, including:
  - which keys were checked
  - where a match was found (current user vs full user record)
  - the resolved numeric user-field ID, if any

---

## Debugging

If hover cards don’t appear where you expect, use the built-in debug mode:

1. Enable **debug_mode** in this component’s settings.
2. Open the browser developer console.
3. Hover or tap a relevant topic link.

You will see messages similar to:

- `Hover cards initialized` – confirms initialization and the enabled locations.
- `Resolved admin user-field mapping` – confirms mapping of your configured user field name / key to a numeric ID (for staff).
- `No disable field match found anywhere` – confirms hover cards are not being suppressed for the current user.

To debug **where** the card should appear, check that:

- your target link is an internal topic link (`/t/...`) that `topicIdFromHref()` can parse
- the relevant location flag is enabled:
  - `enable_on_topics`
  - `enable_on_replies`
  - `enable_on_topic_lists`
  - `enable_on_category_homepage_topic_lists`
  - `enable_on_doc_categories`
  - `enable_on_kanban_boards`
  - `enable_on_suggested_topic_links`

The component’s runtime logic uses the modern JS API initializer pattern described in the **Theme Developer Tutorial: Using the JS API**, and the recommended `service:site` / `service:store` access patterns. [web:827][web:873]

---

## Compatibility & notes

- **Discourse:** Built and tested against Discourse `v2026.4.0-latest` and Ember `v6.10.1`.  
- **Themes:** Intended as a theme component; add it to any theme where you want hover cards.
- **Other components:** If you also customize homepage content (e.g. custom Categories + Latest implementations, Doc Categories, or Kanban components), ensure their CSS does not hide `.topic-hover-card-tooltip` or block pointer events on links.

For more on theme/component structure and git-based workflows, see: [Structure of themes and theme components](https://meta.discourse.org/t/structure-of-themes-and-theme-components/60848) and the theme developer tutorials. [web:409][web:645]
