import gleam/string
import lustre/element
import me/djot
import pamphlet
import pamphlet/lustre as pamphlet_lustre

pub fn heading_id_matches_legacy_routes_test() {
  assert djot.heading_id("What's-next") == "whats-next"
  assert djot.heading_id("Setup-a-VPS.") == "setup-a-vps"
  assert djot.heading_id("Conclusion:-Variants-Aren’t-Worth-the-Hassle")
    == "conclusion-variants-arent-worth-the-hassle"
}

pub fn migrated_constructs_render_test() {
  let source =
    "## Text editing is {-intuitive-} familiar

_emphasis_ and *strong*.

Approximately \\~7 devices and _code_ `inside` _emphasis_.

````=html
<script>window.loaded = true</script>
````"
  let #(_, document) = pamphlet.parse(source)
  let html =
    document
    |> djot.normalize_headings()
    |> pamphlet_lustre.to_lustre(djot.renderer())
    |> fn(render) { render(fn(value) { value }) }
    |> element.to_string()

  assert string.contains(html, "id=\"text-editing-is-intuitive-familiar\"")
  assert string.contains(html, "<del>intuitive</del>")
  assert string.contains(html, "<em>emphasis</em>")
  assert string.contains(html, "<strong>strong</strong>")
  assert string.contains(html, "Approximately ~7 devices")
  assert string.contains(html, "<em>code</em> <code>inside</code>")
  assert string.contains(html, "<script>window.loaded = true</script>")
  assert string.contains(html, "<pamphlet-raw>")
}
