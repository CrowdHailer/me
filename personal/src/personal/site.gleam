import filepath
import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string
import lustre/element
import me/build.{type Context, type Error}
import me/build/files
import midas/continuation
import pamphlet
import pamphlet/lustre as pamphlet_lustre
import personal/gallery
import personal/image
import personal/layout

const output_directory = "public"

pub type Validation {
  Validation(missing: List(String), extra: List(String), changed: List(String))
}

pub fn build(context: Context(t)) {
  use Nil <- continuation.try_then(context.empty_directory(output_directory))
  use Nil <- continuation.try_then(copy_static_files(context))
  use Nil <- continuation.try_then(copy_gallery_originals(context))
  use Nil <- continuation.try_then(generate_gallery_images(context))
  use Nil <- continuation.try_then(copy_client_modules(context))
  use Nil <- continuation.try_then(write_home(context))
  use Nil <- continuation.try_then(write(
    context,
    "public/gallery/index.html",
    layout.gallery(gallery.images),
  ))
  use Nil <- continuation.try_then(files.copy_file(
    context,
    "templates/log.html",
    "public/log/index.html",
  ))
  use Nil <- continuation.try_then(
    context.write_file("public/404.html", <<not_found:utf8>>),
  )
  use Nil <- continuation.try_then(
    context.write_file("public/robots.txt", <<robots:utf8>>),
  )
  use Nil <- continuation.try_then(
    context.write_file("public/sitemap.xml", <<sitemap:utf8>>),
  )
  continuation.done(Nil)
}

pub fn validate(context: Context(t), reference: String) {
  let reference = normalize_root(reference)
  use expected_paths <- continuation.try_then(files.collect_files(
    context,
    reference,
  ))
  use actual_paths <- continuation.try_then(files.collect_files(
    context,
    output_directory,
  ))
  let expected = list.map(expected_paths, relative(_, reference))
  let actual = list.map(actual_paths, relative(_, output_directory))
  let missing = list.filter(expected, fn(path) { !list.contains(actual, path) })
  let extra = list.filter(actual, fn(path) { !list.contains(expected, path) })
  let common = list.filter(expected, fn(path) { list.contains(actual, path) })
  use comparisons <- continuation.try_then(
    continuation.try_each(common, fn(path) {
      use expected_bits <- continuation.try_then(
        context.read_file(filepath.join(reference, path)),
      )
      use actual_bits <- continuation.try_then(
        context.read_file(filepath.join(output_directory, path)),
      )
      continuation.done(#(path, expected_bits != actual_bits))
    }),
  )
  let changed =
    comparisons
    |> list.filter(fn(item) { item.1 })
    |> list.map(fn(item) { item.0 })
  continuation.done(Validation(missing:, extra:, changed:))
}

fn copy_static_files(context: Context(t)) {
  use Nil <- continuation.try_then(files.copy_file(
    context,
    "static/cover.jpg",
    "public/cover.jpg",
  ))
  use Nil <- continuation.try_then(files.copy_file(
    context,
    "static/main.js",
    "public/main.js",
  ))
  use Nil <- continuation.try_then(files.copy_tree(
    context,
    "static/log",
    "public/log",
  ))
  continuation.done(Nil)
}

fn copy_gallery_originals(context: Context(t)) {
  use entries <- continuation.try_then(context.read_directory("content/gallery"))
  use _ <- continuation.try_then(
    continuation.try_each(
      list.filter(entries, fn(entry) { string.ends_with(entry, ".jpg") }),
      fn(entry) {
        files.copy_file(
          context,
          filepath.join("content/gallery", entry),
          filepath.join("public/gallery", entry),
        )
      },
    ),
  )
  continuation.done(Nil)
}

fn generate_gallery_images(context: Context(t)) {
  use Nil <- continuation.try_then(context.empty_directory(
    "public/processed_images",
  ))
  let commands =
    gallery.images
    |> list.map(fn(item) {
      let gallery.Image(source, destination, width, height, _) = item
      image.resize_command(
        filepath.join("content/gallery", source),
        filepath.join("public/processed_images", destination),
        width,
        height,
      )
    })
    |> string.join("\n")
  context.run_commands(commands)
}

fn copy_client_modules(context: Context(t)) {
  use Nil <- continuation.try_then(files.copy_file(
    context,
    "build/dev/javascript/prelude.mjs",
    "public/generated_scripts/prelude.mjs",
  ))
  use Nil <- continuation.try_then(
    files.copy_tree_matching(
      context,
      "build/dev/javascript/personal",
      "public/generated_scripts/personal",
      fn(path) { string.ends_with(path, ".mjs") },
    ),
  )
  use Nil <- continuation.try_then(
    files.copy_tree_matching(
      context,
      "build/dev/javascript/gleam_stdlib",
      "public/generated_scripts/gleam_stdlib",
      fn(path) { string.ends_with(path, ".mjs") },
    ),
  )
  continuation.done(Nil)
}

fn write_home(context: Context(t)) {
  use source_bits <- continuation.try_then(context.read_file(
    "content/_index.md",
  ))
  use source <- continuation.try(text("content/_index.md", source_bits))
  let #(_, document) = pamphlet.parse(source)
  use content <- continuation.then(pamphlet_lustre.to_lustre(
    document,
    pamphlet_lustre.default(),
  ))
  use template_bits <- continuation.try_then(context.read_file(
    "templates/index.html",
  ))
  use template <- continuation.try(text("templates/index.html", template_bits))
  use css <- continuation.try(extract_css(template))
  let html =
    layout.home(content, css)
    |> element.to_document_string()
    |> string.replace("id=\"Current-work\"", "id=\"current-work\"")
    |> string.replace("id=\"Contact\"", "id=\"contact\"")
  context.write_file("public/index.html", <<html:utf8>>)
}

fn write(context: Context(t), path: String, document) {
  context.write_file(path, <<element.to_document_string(document):utf8>>)
}

fn text(path: String, bits: BitArray) -> Result(String, Error) {
  bits
  |> bit_array.to_string()
  |> result.map_error(fn(_) { build.InvalidText(path) })
}

fn extract_css(template: String) -> Result(String, Error) {
  use #(_, after_start) <- result.try(
    string.split_once(template, "<style>")
    |> result.map_error(fn(_) { build.InvalidTemplate("templates/index.html") }),
  )
  use #(css, _) <- result.try(
    string.split_once(after_start, "</style>")
    |> result.map_error(fn(_) { build.InvalidTemplate("templates/index.html") }),
  )
  Ok(css)
}

fn relative(path: String, root: String) {
  string.drop_start(path, string.length(root <> "/"))
}

fn normalize_root(root: String) {
  case string.ends_with(root, "/") {
    True -> string.drop_end(root, 1)
    False -> root
  }
}

const not_found = "<!doctype html>
<title>404 Not Found</title>
<h1>404 Not Found</h1>
"

const robots = "User-agent: *
Allow: /
Sitemap: https://petersaxton.uk/sitemap.xml
"

const sitemap = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">
    <url>
        <loc>https://petersaxton.uk/</loc>
    </url>
    <url>
        <loc>https://petersaxton.uk/gallery/</loc>
    </url>
    <url>
        <loc>https://petersaxton.uk/log/</loc>
    </url>
</urlset>
"
