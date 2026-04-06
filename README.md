# Discourse Topic Hover Cards

A Discourse theme component that shows a rich topic preview card when users hover over internal topic links.

This component was inspired by the idea behind topic cards, but instead of changing the main topic list layout, it displays a compact hover card anywhere topic links appear across your forum.

## Features

- Show a topic preview card on hover for internal topic links
- Works in configurable areas:
  - Topics
  - Replies
  - Topic lists
  - Suggested topic links
- Optional display of:
  - Thumbnail
  - Category
  - Tags
  - Title
  - Excerpt
  - Original poster
  - Publish date
  - Views
  - Reply count
  - Likes
  - Last activity
- Configurable thumbnail placement on desktop:
  - Top
  - Left
  - Right
  - Bottom
- Configurable image size as a percentage of the hover card width
- Configurable excerpt length
- Configurable card width and max height using any valid CSS value
- Mobile support with a dedicated mobile preview experience
- In-memory caching for faster repeat hovers
- Automatic viewport-aware positioning above or below the hovered link on desktop

## Installation

Install this as a remote theme component in Discourse:

1. Go to **Admin → Appearance → Themes & components**. [web:366]
2. Open the **Components** tab. [web:366]
3. Click **Install**. [web:366]
4. Choose **From a git repository**. [web:366]
5. Paste this repository URL.
6. Install the component.
7. Add the component to one or more active themes using the component/theme inclusion settings. [web:366][web:89]

## Desktop behavior

On desktop, when a user hovers over a supported internal topic link, the component fetches the topic data and displays a floating preview card near the link.

Desktop behavior includes:

- Hover delay before opening
- Automatic placement above or below the link depending on viewport space
- Viewport clamping to avoid rendering off-screen
- Configurable thumbnail placement
- Rich metadata display based on enabled settings

## Mobile behavior

When mobile support is enabled, the component uses a mobile-specific preview interaction instead of desktop hover behavior.

Mobile behavior includes:

- Tap a supported internal topic link to open the preview card
- The preview appears as a bottom sheet anchored to the bottom of the screen
- A red **close** button appears in the top-right corner of the card
- A full-width **Open topic** button appears at the bottom of the card
- The thumbnail is always shown at the top on mobile, regardless of desktop thumbnail placement
- Admins can choose separate mobile visibility settings for most card elements

This replaces the earlier “tap again to open” interaction with explicit mobile controls.

## Settings

### Card sizing

- `card_width`  
  Accepts any valid CSS width value, for example:
  - `32rem`
  - `420px`
  - `40vw`
  - `clamp(20rem, 40vw, 36rem)`

- `card_max_height`  
  Accepts any valid CSS max-height value, for example:
  - `10rem`
  - `480px`
  - `50vh`
  - `min(60vh, 32rem)`

### Behavior

- `card_delay_ms`  
  Delay in milliseconds before the card appears on hover.

- `enable_on_mobile`  
  Enables the mobile tap-to-preview experience.

### Area targeting

- `enable_on_topics`  
  Show hover cards for topic links inside the original post.

- `enable_on_replies`  
  Show hover cards for topic links inside replies.

- `enable_on_topic_lists`  
  Show hover cards for topic links in topic lists.

- `enable_on_suggested_topic_links`  
  Show hover cards for topic links in the suggested topics area.

## Desktop content settings

- `show_thumbnail`
- `thumbnail_placement`
- `image_size_percent`
- `show_category`
- `show_tags`
- `show_title`
- `show_excerpt`
- `excerpt_length`
- `show_op`
- `show_publish_date`
- `show_views`
- `show_reply_count`
- `show_likes`
- `show_activity`

## Mobile-specific settings

The component includes mobile-specific versions of the main content settings so the preview can be more compact or more detailed on phones.

### Mobile display toggles

- `show_thumbnail_mobile`
- `show_category_mobile`
- `show_tags_mobile`
- `show_title_mobile`
- `show_excerpt_mobile`
- `show_op_mobile`
- `show_publish_date_mobile`
- `show_views_mobile`
- `show_reply_count_mobile`
- `show_likes_mobile`
- `show_activity_mobile`

### Mobile layout controls

- `image_size_percent_mobile`
- `excerpt_length_mobile`

## Defaults

Current defaults:

- `card_width: "32rem"`
- `card_max_height: "10rem"`
- `card_delay_ms: 300`
- `enable_on_mobile: false`
- `enable_on_topics: true`
- `enable_on_replies: true`
- `enable_on_topic_lists: true`
- `enable_on_suggested_topic_links: true`

### Desktop defaults

- `show_thumbnail: true`
- `thumbnail_placement: left`
- `image_size_percent: 30`
- `show_category: true`
- `show_tags: true`
- `show_title: true`
- `show_excerpt: true`
- `excerpt_length: 3`
- `show_op: true`
- `show_publish_date: true`
- `show_views: true`
- `show_reply_count: true`
- `show_likes: true`
- `show_activity: true`

### Mobile defaults

- `show_thumbnail_mobile: true`
- `image_size_percent_mobile: 100`
- `show_category_mobile: true`
- `show_tags_mobile: true`
- `show_title_mobile: true`
- `show_excerpt_mobile: true`
- `excerpt_length_mobile: 2`
- `show_op_mobile: true`
- `show_publish_date_mobile: true`
- `show_views_mobile: true`
- `show_reply_count_mobile: true`
- `show_likes_mobile: true`
- `show_activity_mobile: false`

## How it works

The component listens for supported internal topic links and checks whether the hovered or tapped link is inside one of the enabled areas. It then fetches the topic JSON from Discourse using the topic ID from the link URL, builds a preview card, and displays it as either a desktop tooltip or a mobile bottom sheet. Discourse theme components commonly use API initializers, repository-defined settings, and localized admin labels for this kind of behavior. [web:365][web:22][web:237]

The card currently pulls data from both the topic JSON and Discourse’s client-side site/category data so it can render topic metadata more reliably. Theme components are structured as a collection of repository files such as `about.json`, `settings.yml`, SCSS, JavaScript initializers, and locale files. [web:409][web:365]

## Content sources

The card currently uses:

- Topic title
- Topic excerpt or first-post cooked content
- Topic thumbnail
- Category resolved from `category_id`
- Tags normalized from string or object form
- Original poster username and avatar
- Publish date
- View count
- Reply count
- Like count
- Last activity date

## Mobile interaction notes

When mobile support is enabled:

- The preview opens from a tap on a supported internal topic link
- The **Open topic** button is the primary action for navigation
- The red **close** button dismisses the preview without navigating
- The card is designed to be easier to use on touch devices than a repeated tap-to-open pattern

## Notes

- Only internal Discourse topic links are supported.
- External links are ignored.
- Scrolls inside the hover card do not close the card.
- Scrolls outside the card close the card.
- Category display depends on the category being resolvable through Discourse’s client-side category data.
- Tag rendering supports both plain strings and object-shaped tag data.
- On mobile, the card is presented as a bottom sheet rather than a floating tooltip.

## File structure

```text
discourse-topic-hover-cards/
├── about.json
├── settings.yml
├── common/
│   └── common.scss
├── javascripts/
│   └── discourse/
│       └── api-initializers/
│           └── discourse-topic-hover-cards.gjs
├── locales/
│   └── en.yml
└── .discourse-compatibility
```

## Compatibility

This component is intended for modern Discourse versions and should be used as a remote theme component with current Discourse theme APIs. Theme components are the preferred packaging format for focused UI enhancements like this. [web:409][web:365]

## Development

If you are developing this locally:

- Keep settings in `settings.yml`, because Discourse theme settings are defined repository-side. [web:22]
- Keep JavaScript in `javascripts/discourse/api-initializers/` for API initializer loading. [web:365]
- Keep translations in `locales/en.yml`, where theme and component strings are localized. [web:237]
- Keep shared styles in `common/common.scss`. Common styles apply to both desktop and mobile unless you intentionally split them into separate mobile/desktop files. [web:47][web:404]

## Credits

Inspired by the Discourse Topic Cards concept, adapted into a hover-preview component for use inside posts, replies, topic lists, and suggested-topic links. The original Topic Cards component is a separate Discourse theme component focused on restyling topic lists as cards. [web:370][web:30]
