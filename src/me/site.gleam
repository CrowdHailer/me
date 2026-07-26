import filepath
import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string
import lustre/element
import me/build.{type Context, type Error}
import me/build/files
import me/djot
import me/layout
import me/path as site_path
import midas/continuation
import pamphlet
import pamphlet/document
import pamphlet/lustre as pamphlet_lustre

const output_directory = "_site"

const excluded_directories = [
  "_site",
  "build",
  "personal",
  "src",
]

const excluded_files = [
  ".gitignore",
  "gleam.toml",
  "manifest.toml",
]

pub fn build(context: Context(t)) {
  use Nil <- continuation.try_then(context.empty_directory(output_directory))
  use paths <- continuation.try_then(walk(context, ".", True))
  use _ <- continuation.try_then(
    continuation.try_each(paths, fn(path) { build_file(context, path) }),
  )
  continuation.done(Nil)
}

fn build_file(context: Context(t), path: String) {
  let relative = site_path.strip_root(path, ".")
  case should_exclude_file(relative), filepath.extension(path) {
    True, _ -> continuation.done(Nil)
    False, Ok("html") | False, Ok("md") -> {
      use bits <- continuation.try_then(context.read_file(path))
      use source <- continuation.try(text(path, bits))
      case document.take_frontmatter(source) {
        Ok(#(frontmatter, body)) ->
          render_page(context, path, relative, frontmatter, body)
        Error(Nil) -> copy_file(context, path, relative)
      }
    }
    False, _ -> copy_file(context, path, relative)
  }
}

fn render_page(
  context: Context(t),
  source_path: String,
  relative: String,
  frontmatter: String,
  body: String,
) {
  let metadata = document.parse_frontmatter(frontmatter)
  let output = site_path.output_path(output_directory, relative)
  let url = site_path.page_url(output_directory, output)
  let page = layout.Page(url:, metadata:, content: element.none())
  case filepath.extension(source_path) {
    Ok("md") -> {
      let #(_, parsed) =
        pamphlet.parse("---\n" <> frontmatter <> "---\n" <> body)
      use content <- continuation.then(pamphlet_lustre.to_lustre(
        djot.normalize_headings(parsed),
        djot.renderer(),
      ))
      let page = layout.Page(..page, content: content)
      let rendered = case layout.metadata(metadata, "layout", "default") {
        "article" -> layout.article(page)
        _ -> layout.default(page, layout.default_body(content))
      }
      context.write_file(output, <<document_string(rendered):utf8>>)
    }
    _ -> {
      let rendered = case layout.metadata(metadata, "layout", "default") {
        "article" -> layout.article_raw(page, body)
        _ -> layout.default_raw(page, body)
      }
      context.write_file(output, <<element.to_document_string(rendered):utf8>>)
    }
  }
}

fn document_string(document) {
  document
  |> element.to_document_string()
  |> string.replace("<pamphlet-raw>", "")
  |> string.replace("</pamphlet-raw>", "")
}

fn copy_file(context: Context(t), source: String, relative: String) {
  files.copy_file(context, source, filepath.join(output_directory, relative))
}

fn walk(
  context: Context(t),
  root: String,
  repository_root: Bool,
) -> continuation.Task(t, List(String), Error) {
  use entries <- continuation.try_then(context.read_directory(root))
  use nested <- continuation.try_then(
    continuation.try_each(entries, fn(entry) {
      let path = filepath.join(root, entry)
      use directory <- continuation.try_then(context.is_directory(path))
      case
        directory,
        site_path.is_hidden(entry)
        || { repository_root && list.contains(excluded_directories, entry) }
      {
        True, True -> continuation.done([])
        True, False -> walk(context, path, False)
        False, _ -> continuation.done([path])
      }
    }),
  )
  continuation.done(list.flatten(nested))
}

fn should_exclude_file(path: String) -> Bool {
  site_path.is_hidden(path) || list.contains(excluded_files, path)
}

fn text(path: String, bits: BitArray) -> Result(String, Error) {
  bits
  |> bit_array.to_string()
  |> result.map_error(fn(_) { build.InvalidText(path) })
}
