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
- Configurable thumbnail placement:
  - Top
  - Left
  - Right
  - Bottom
- Configurable image size as a percentage of the hover card width
- Configurable excerpt length
- Configurable card width and max height using any valid CSS value
- Mobile support with optional tap-to-preview behavior
- In-memory caching for faster repeat hovers
- Automatic viewport-aware positioning above or below the hovered link

## Installation

Install this as a remote theme component in Discourse:

1. Go to **Admin → Appearance → Themes & Components**.
2. Open the **Components** tab.
3. Click **Install**.
4. Choose **From a git repository**.
5. Paste this repository URL.
6. Install the component.
7. Add the component to one or more active themes using the component/theme inclusion settings.

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
  Enables tap-to-preview behavior on touch devices.

### Area targeting

- `enable_on_topics`  
  Show hover cards for topic links inside the original post.

- `enable_on_replies`  
  Show hover cards for topic links inside replies.

- `enable_on_topic_lists`  
  Show hover cards for topic links in topic lists.

- `enable_on_suggested_topic_links`  
  Show hover cards for topic links in the suggested topics area.

### Content toggles

- `show_thumbnail`
- `show_category`
- `show_tags`
- `show_title`
- `show_excerpt`
- `show_op`
- `show_publish_date`
- `show_views`
- `show_reply_count`
- `show_likes`
- `show_activity`

### Layout controls

- `thumbnail_placement`  
  Options:
  - `top`
  - `left`
  - `right`
  - `bottom`

- `image_size_percent`  
  Controls the image width as a percentage of the hover card width for left/right thumbnail layouts.

- `excerpt_length`  
  Controls the number of excerpt lines shown.

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
- `show_thumbnail: true`
- `show_category: true`
- `show_tags: true`
- `thumbnail_placement: left`
- `image_size_percent: 30`
- `show_title: true`
- `show_excerpt: true`
- `excerpt_length: 3`
- `show_op: true`
- `show_publish_date: true`
- `show_views: true`
- `show_reply_count: true`
- `show_likes: true`
- `show_activity: true`

## How it works

The component listens for hover events on internal topic links and checks whether the hovered link is inside one of the enabled areas. It then fetches the topic JSON from Discourse using the topic ID from the link URL, builds a preview card, and displays it in a floating tooltip. Discourse theme components commonly use API initializers and repository-based settings files for this kind of behavior. [web:22][web:78][web:71]

The card is positioned below the hovered link by default, and automatically flips above the link when there is not enough room below it. The card also clamps itself within the viewport horizontally so it does not render off-screen. [web:78]

## Content sources

The card currently pulls data from the topic JSON and from Discourse’s client-side site/category data:

- Topic title
- Topic excerpt or first-post cooked content
- Topic thumbnail
- Category resolved from `category_id`
- Tags normalized from string or object form
- Original poster username and avatar
- Publish date
- View count
- Reply count
- Likes
- Last activity date

## Mobile behavior

When mobile support is enabled:

- Tapping a supported internal topic link opens the hover card as a bottom sheet
- Tapping the same link again closes it
- Thumbnail placement is forced to `top` on mobile for a cleaner layout

## Notes

- Only internal Discourse topic links are supported.
- The component ignores external links.
- Scrolls inside the hover card do not close the card.
- Scrolls outside the card close the card.
- Category display depends on the category being resolvable through the client-side Discourse category data.
- Tag rendering supports both plain strings and object-shaped tag data.

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

This component is intended for modern Discourse versions and should be used as a remote theme component with current Discourse theme APIs. Theme components are the preferred packaging format for focused UI enhancements like this. [web:371][web:364]

## Development

If you are developing this locally:

- Keep settings in `settings.yml` because Discourse theme settings are defined repository-side rather than through the admin code editor. [web:22]
- Keep JavaScript in the `javascripts/discourse/api-initializers/` directory for API initializer loading. [web:78][web:71]
- Keep styles in `common/common.scss`.

## Credits

Inspired by the Discourse Topic Cards concept, adapted into a hover-preview component for use inside posts, replies, topic lists, and suggested-topic links. The original Topic Cards component is a separate Discourse theme component focused on restyling topic lists as cards. [web:370][web:40]
