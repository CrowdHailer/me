import filepath
import gleam/list
import gleam/string

pub fn output_path(output_directory: String, relative: String) -> String {
  case string.ends_with(relative, ".md") {
    True ->
      filepath.join(output_directory, string.drop_end(relative, 3) <> ".html")
    False -> filepath.join(output_directory, relative)
  }
}

pub fn page_url(output_directory: String, output: String) -> String {
  let relative = strip_root(output, output_directory)
  case relative {
    "index.html" -> "/"
    _ ->
      case string.ends_with(relative, "/index.html") {
        True -> "/" <> string.drop_end(relative, string.length("index.html"))
        False -> "/" <> relative
      }
  }
}

pub fn strip_root(path: String, root: String) -> String {
  let prefix = root <> "/"
  case string.starts_with(path, prefix) {
    True -> string.drop_start(path, string.length(prefix))
    False -> path
  }
}

pub fn is_hidden(name: String) -> Bool {
  name
  |> string.split("/")
  |> list.any(fn(segment) { string.starts_with(segment, ".") })
}
