# Mysig SSG Migration Plan

Branch: `mysig-ssg-migration`.

## Sites

- Root site: Jekyll-style `crowdhailer.me`, with existing HTML pages, newer
  Markdown articles, article/default layouts, slide pages, talks, CV, and
  static media.
- `personal/`: Zola site for `petersaxton.uk`, with content sections,
  templates, gallery images, video log media, generated Gleam JavaScript, and
  Netlify preview URL behaviour.

## Feature Parity Checklist

- Preserve all current public routes.
- Preserve existing HTML pages as passthrough pages until each can be converted.
- Render Markdown/Djot articles with front matter through Pamphlet.
- Rebuild article/default layouts as Lustre functions.
- Preserve slide pages and talks without route changes.
- Preserve gallery image paths and video assets.
- Support base URL configuration and deploy preview override.
- Generate static files into the same publish directory expected by Netlify.
- Add a route diff against the current generator output before switching deploys.

## Migration Order

1. Build Mysig SSG feature parity in `../mysig` on branch `ssg`.
2. Add a local Gleam project in this repository that depends on `../mysig`.
3. Port the root site route tree and layouts.
4. Port `personal/` content sections and templates.
5. Add output parity checks and screenshot comparisons.
6. Replace Netlify build commands only after generated output matches current
   public routes.
