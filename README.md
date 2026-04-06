# Discourse Topic Hover Cards

A Discourse theme component that shows rich preview cards for internal topic links across topics, replies, topic lists, and suggested topics.

## Features

- Rich hover preview cards for internal topic links
- Desktop hover support
- Optional mobile tap-to-preview bottom sheet
- Configurable desktop width and max height
- Configurable mobile width and thumbnail height
- Configurable desktop thumbnail placement
- Separate desktop/mobile density settings
- Separate desktop/mobile content visibility settings
- Per-user disable toggle via custom user field
- Topic JSON fetch caching for repeated previews

## Installation

In Discourse Admin:

1. Go to **Admin → Appearance → Themes & Components**
2. Open the **Components** tab
3. Click **Install**
4. Choose **From a git repository**
5. Enter the repository URL
6. Install the component
7. Add the component to your active theme via **Include component on these themes**

Discourse supports installing theme components directly from git repositories. After installation, add the component to one or more active themes.

## Settings

### Layout and behavior

- `card_width`  
  Any valid CSS width value for desktop cards, such as `32rem`, `420px`, `40vw`, or `clamp(20rem, 40vw, 36rem)`.

- `card_max_height`  
  Any valid CSS max-height value for desktop cards, such as `10rem`, `480px`, `50vh`, or `min(60vh, 32rem)`.

- `card_delay_ms`  
  Delay in milliseconds before the hover card appears.

- `enable_on_mobile`  
  Enables tap-to-preview behavior on touch devices.

### Placement and sizing

- `thumbnail_placement`  
  Desktop thumbnail placement: `top`, `left`, `right`, or `bottom`.

- `image_size_percent`  
  For desktop left/right layouts, controls the thumbnail width as a percentage of the card width.

- `mobile_width_percent`  
  Controls the mobile preview width as a percentage of the viewport width.

- `mobile_thumbnail_height`  
  Controls the mobile thumbnail height in pixels.

### Density

This component includes separate desktop and mobile density settings that match the relative options used by the Discourse Density Toggle component:

- `default`
- `cozy`
- `compact`

Settings:

- `density`  
  Controls desktop hover card density.

- `density_mobile`  
  Controls mobile hover card density.

Density settings adjust the compactness of the hover card content, including spacing, padding, gaps, and text rhythm.

Density settings do **not** control desktop thumbnail size.

Desktop thumbnail size and placement are controlled by these layout settings instead:

- `thumbnail_placement`
- `image_size_percent`

Mobile thumbnail size is controlled separately by:

- `mobile_thumbnail_height`
- Note: Density affects content rhythm, not thumbnail dimensions. (Density settings do not change thumbnail dimensions. Desktop thumbnail size is controlled by `thumbnail_placement` and `image_size_percent`, while mobile thumbnail height is controlled by `mobile_thumbnail_height`.)

This separation is intentional:

- layout settings control image size and placement
- density settings control spacing and content compactness
- visibility settings control which content elements appear

### Content visibility

Desktop and mobile each have separate settings for:

- thumbnail
- category
- tags
- title
- excerpt
- original poster
- publish date
- views
- reply count
- likes
- last activity

## Per-user disable toggle

This component supports a per-user preference so an individual user can disable hover cards for their own account.

### Theme setting

- `user_preference_field_name`  
  The custom user field key used to disable hover cards per user.

Default:

```text
disable_topic_hover_cards
```

### How it works

When the component loads, it checks the current user for the configured custom user field. If the field contains a truthy value, the hover-card behavior does not initialize for that user.

Accepted truthy values include:

- `true`
- `1`
- `"1"`
- `"true"`
- `"yes"`
- `"on"`
- `"checked"`

## Admin setup for the per-user toggle

Create a custom user field in Discourse Admin.

Suggested setup:

- **Label:** `Disable topic hover cards`
- **Description:** `Turn off topic hover cards for this account`
- **Type:** checkbox / confirmation style field
- **Editable by user:** enabled
- **Shown in preferences or editable profile UI:** enabled

Then set the component setting:

```text
user_preference_field_name = disable_topic_hover_cards
```

The field key on your site must match the value configured in the theme setting.

## Mobile behavior

When mobile support is enabled:

- tapping a supported internal topic link opens a bottom-sheet preview
- the bottom sheet width is controlled by `mobile_width_percent`
- the image height is controlled by `mobile_thumbnail_height`
- the mobile layout density is controlled by `density_mobile`

## Supported link locations

Hover cards can be enabled independently for:

- links in topic bodies
- links in replies
- links in topic lists
- links in suggested topics

## Notes

- Only internal topic links are targeted.
- External links are ignored.
- The per-user custom field disables the component for that specific user only.
- Global mobile disable still overrides user-level preference for mobile behavior because the component does not initialize mobile previews when mobile is globally off.

## Compatibility

Designed for modern Discourse versions that support theme components, theme settings, theme translations, and JS API initializers.

## Credits

Inspired by card-based topic previews and adapted for hover and mobile preview behavior inside Discourse.
