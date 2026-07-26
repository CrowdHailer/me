import gleam/dict
import gleam/list
import gleam/string
import jot
import lustre/element
import midas/continuation
import pamphlet/lustre as pamphlet_lustre

pub fn renderer() {
  pamphlet_lustre.Renderer(
    ..pamphlet_lustre.default(),
    resolve_raw_block: fn(content) {
      continuation.return(element.unsafe_raw_html(
        "",
        "pamphlet-raw",
        [],
        content,
      ))
    },
    resolve_raw_inline: fn(content) {
      continuation.return(element.unsafe_raw_html(
        "",
        "pamphlet-raw",
        [],
        content,
      ))
    },
  )
}

pub fn normalize_headings(document: jot.Document) -> jot.Document {
  jot.Document(
    ..document,
    content: list.map(document.content, normalize_container),
  )
}

pub fn heading_id(id: String) -> String {
  id
  |> string.lowercase()
  |> string.replace("'", "")
  |> string.replace("’", "")
  |> string.replace(":", "")
  |> string.replace(".", "")
}

fn normalize_container(container: jot.Container) -> jot.Container {
  case container {
    jot.Heading(attributes, level, content) -> {
      let attributes = case dict.get(attributes, "id") {
        Ok(id) -> dict.insert(attributes, "id", heading_id(id))
        Error(Nil) -> attributes
      }
      jot.Heading(attributes, level, content)
    }
    jot.BlockQuote(attributes, items) ->
      jot.BlockQuote(attributes, list.map(items, normalize_container))
    jot.Div(class, attributes, items) ->
      jot.Div(class, attributes, list.map(items, normalize_container))
    jot.BulletList(layout, style, items) ->
      jot.BulletList(
        layout,
        style,
        list.map(items, fn(item) { list.map(item, normalize_container) }),
      )
    jot.OrderedList(layout, punctuation, ordinal, start, items) ->
      jot.OrderedList(
        layout,
        punctuation,
        ordinal,
        start,
        list.map(items, fn(item) { list.map(item, normalize_container) }),
      )
    _ -> container
  }
}
