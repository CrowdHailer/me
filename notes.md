# Migration Notes

## Repository

- The migration is on branch `old-migration` from `gh-pages`.
- Pamphlet is cloned beside this repository at `../pamphlet` and is referenced
  as a local Gleam dependency.
- The new personal website referred to as `./personal` is the existing Zola
  project in this repository.

## Old Site

- `gleam dev build` replaces `jekyll build` and writes `_site/`.
- Pamphlet parses front matter and Djot for generated Markdown pages. The eight
  Kramdown articles remain `.md` files and were migrated in place: strong,
  emphasis, deletion, and raw HTML now use Djot syntax. HTML page bodies have
  no Liquid and remain opaque HTML between their front matter and Lustre
  layout.
- `_layouts/default.html` and `_layouts/article.html` were reimplemented in
  `src/me/layout.gleam`; the Jekyll configuration and layouts were removed.
- Source HTML without front matter, including Remark slide decks containing
  Liquid-like Elixir examples, is copied byte-for-byte.
- Hidden paths, build configuration, `personal/`, and framework source are not
  published. This intentionally avoids exposing the nested personal site's
  source, which Jekyll copied by default.

## Equivalence

The Jekyll 4.1.0 reference build contains 230 files after excluding the nested
`personal/` source and obsolete build configuration. The Gleam build contains
the same 230 paths: no routes or assets are missing or extra. Of 194
passthrough files, 193 are byte-identical; the published `README.md` now
documents the Gleam workflow instead of Jekyll.

The 36 generated HTML files are not byte-identical. Lustre serializes valid
HTML with lowercase doctype, normalized whitespace, reordered attributes, and
omitted empty attribute values. Migrated Djot heading IDs are normalized to the
legacy Jekyll slugs, GitHub Actions expressions remain literal, and raw Vimeo
and EYG embeds are rendered as HTML. `gleam dev validate <reference>` reports
every changed file and fails for missing, extra, or unexpected passthrough
changes.

## Effects

- Site/template functions are pure continuation tasks using the Midas pattern.
  Reads, directory traversal, writes, output cleanup, and image commands are
  passed in through `me/build.Context`.
- `me/build.Program` defunctionalizes those effects. Simplifile is used only by
  the interpreter in `me/build/runtime`, selected in each `*_dev.main` entry
  point. Tests step through requested effects and verify failure
  short-circuiting without performing I/O.
- Pamphlet's own Lustre continuation is composed directly into each build task
  rather than run early with an identity callback.

## Hosting And Development

- `Caddyfile` is the production static-site configuration.
- `HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up --build` starts a
  Simplifile/Gleam build watcher, Caddy, and BrowserSync. Browse on port 3000
  for live reload; Caddy remains the origin serving the static files. All
  development container images are digest-pinned.

## Personal Site

- `personal/` is now a Gleam 1.17 JavaScript-target project. Its own
  `gleam dev build` writes `personal/public/`.
- The home document is parsed by Pamphlet and rendered by Lustre. The gallery
  is a typed Lustre view with a 39-image manifest. The log template is copied
  unchanged because its 82 Vimeo embeds contain intentionally varied and some
  browser-tolerated malformed markup.
- The old Gleam 0.16 browser modules were replaced by a current Gleam speech
  state machine. Browsers without Web Speech support now keep the static site
  usable instead of throwing during module initialization.
- Gallery originals remain content. Derivatives are not committed. The Gleam
  build sends a typed source/output/dimensions manifest to the pinned
  `dpokidov/imagemagick:7.1.1-47` container in one invocation. The generated
  dimensions match all Zola 0.13.0 reference derivatives exactly, metadata is
  stripped, and EXIF orientation is not automatically applied.
- Alakazam defines the typed exact-resize, strip, and quality pipeline. The
  only JavaScript boundary launches all generated commands in one isolated,
  digest-pinned ImageMagick container.
- The derivative JPEG bytes differ because Zola and ImageMagick use different
  encoders. Their routes, dimensions, orientation behavior, and quality target
  are preserved.
- `personal/Caddyfile` serves production and maps missing paths to the generated
  404 page. The documented Compose command supplies the absolute host project
  path and host UID/GID, then runs the Gleam watcher, Caddy, and BrowserSync on
  port 3000. The builder owns the Docker socket, but the ImageMagick child is
  given only the personal project mount.
