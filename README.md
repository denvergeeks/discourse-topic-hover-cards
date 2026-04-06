# Discourse Topic Hover Cards

A Discourse theme component that shows rich topic preview cards when users interact with internal topic links.

This component was inspired by the idea behind topic cards, but instead of changing the main topic list layout, it displays a compact preview card anywhere supported topic links appear across your forum.

## Features

- Show a topic preview card for internal topic links
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
- Desktop thumbnail placement options:
  - Top
  - Left
  - Right
  - Bottom
- Desktop thumbnail width control
- Mobile thumbnail height control
- Configurable excerpt length
- Configurable card width and max height using valid CSS values
- Mobile-specific display settings
- In-memory caching for faster repeat previews
- Desktop viewport-aware positioning above or below the hovered link
- Mobile bottom-sheet preview with explicit close and open controls

## Installation

Install this as a remote theme component in Discourse:

1. Go to **Admin → Appearance → Themes & components**. [web:366]
2. Open the **Components** tab. [web:366]
3. Click **Install**. [web:366]
4. Choose **From a git repository**. [web:366]
5. Paste this repository URL.
6. Install the component.
7. Add the component to one or more active themes using either:
   - the component’s **Include component on these themes** setting, or
   - the theme’s **Included components** section. [web:366][web:89]

## How it works

The component watches supported internal topic links and fetches topic JSON from Discourse when a preview is needed. It then builds a preview card using topic data and Discourse’s client-side category information, which is a normal pattern for Discourse theme components built with repository files, settings, styles, and JS initializers. [web:365][web:409]

On desktop, the card appears as a floating tooltip near the hovered link. On mobile, the card opens as a bottom sheet after tapping a supported internal topic link. [web:317][web:389]

## Desktop behavior

On desktop, when a user hovers over a supported internal topic link, the component displays a floating preview card near that link.

Desktop behavior includes:

- Hover delay before opening
- Automatic placement above or below the link depending on available viewport space
- Horizontal clamping so the card does not render off-screen
- Configurable thumbnail placement
- Configurable thumbnail width percentage for left and right layouts
- Rich metadata display based on enabled settings

## Mobile behavior

When mobile support is enabled, the component uses a dedicated mobile preview interaction instead of desktop hover behavior.

Mobile behavior includes:

- Tap a supported internal topic link to open the preview
- Preview opens as a bottom sheet anchored to the bottom of the screen
- A red close button appears in the top-right corner of the preview
- A full-width **Open topic** button appears at the bottom of the preview
- Tapping inside the preview does not navigate unless the user taps **Open topic**
- Thumbnail placement is always top-aligned on mobile
- Thumbnail size on mobile is controlled by a dedicated mobile thumbnail-height setting
- Mobile-specific content visibility settings allow a lighter or denser mobile layout

## Settings

### Card sizing

- `card_width`  
  Any valid CSS width value, such as:
  - `32rem`
  - `420px`
  - `40vw`
  - `clamp(20rem, 40vw, 36rem)`

- `card_max_height`  
  Any valid CSS max-height value, such as:
  - `10rem`
  - `480px`
  - `50vh`
  - `min(60vh, 32rem)`

### Behavior

- `card_delay_ms`  
  Delay in milliseconds before the desktop hover card appears.

- `enable_on_mobile`  
  Enables the mobile tap-to-preview bottom-sheet experience.

### Area targeting

- `enable_on_topics`  
  Show preview cards for topic links inside the original post.

- `enable_on_replies`  
  Show preview cards for topic links inside replies.

- `enable_on_topic_lists`  
  Show preview cards for topic links in topic lists.

- `enable_on_suggested_topic_links`  
  Show preview cards for topic links in the suggested topics area.

## Desktop display settings

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

### Desktop image sizing

- `image_size_percent`  
  Controls thumbnail width for desktop left and right thumbnail layouts.

## Mobile display settings

- `show_thumbnail_mobile`
- `show_category_mobile`
- `show_tags_mobile`
- `show_title_mobile`
- `show_excerpt_mobile`
- `excerpt_length_mobile`
- `show_op_mobile`
- `show_publish_date_mobile`
- `show_views_mobile`
- `show_reply_count_mobile`
- `show_likes_mobile`
- `show_activity_mobile`

### Mobile image sizing

- `image_size_percent_mobile`  
  Controls the mobile thumbnail height in the bottom-sheet layout. Higher values make the mobile image taller.

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

## Content sources

The preview card currently uses:

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

## Screenshots

### Desktop hover card

Add a desktop screenshot here once available:

```md

```

### Mobile bottom sheet

Add a mobile screenshot here once available:

```md

```

### Mobile actions

Add a second mobile screenshot showing the close button and action button:

```md

```

GitHub README images are typically added using relative paths to image files committed into the repository. [web:474][web:476]

## Notes

- Only internal Discourse topic links are supported.
- External links are ignored.
- Scrolls inside the preview card do not close the card.
- Scrolls outside the card close the card.
- Category display depends on category data being resolvable through Discourse’s client-side category information.
- Tag rendering supports both plain strings and object-shaped tag data.
- On mobile, the preview is shown as a bottom sheet rather than a floating tooltip.
- On desktop, thumbnail width is configurable for side-image layouts.
- On mobile, thumbnail height is configurable for the bottom-sheet layout.

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

This component is intended for modern Discourse versions and should be used as a remote theme component with current Discourse theme APIs. Theme components are the preferred packaging format for focused UI enhancements like this. [web:365][web:409]

## Development

If you are developing this locally:

- Keep settings in `settings.yml`, because Discourse theme settings are defined repository-side. [web:409]
- Keep JavaScript in `javascripts/discourse/api-initializers/` for API initializer loading. [web:365]
- Keep translations in `locales/en.yml`, where theme and component strings are localized. [web:379]
- Keep shared styles in `common/common.scss`. `common.scss` applies to both desktop and mobile unless you intentionally scope behavior with media queries. [web:239][web:464]

## Credits

Inspired by the general Topic Cards concept, adapted into a hover and tap preview component for use inside posts, replies, topic lists, and suggested-topic links. The original Topic Cards approach is a separate Discourse theme component focused on restyling topic lists as cards. [web:317]
