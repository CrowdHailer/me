import gleam/string
import gleeunit/should
import lustre/element
import lustre/element/html as h
import me/layout

pub fn metadata_fallback_test() {
  layout.metadata([], "title", "fallback")
  |> should.equal("fallback")
}

pub fn metadata_value_test() {
  layout.metadata([#("title", "Page")], "title", "fallback")
  |> should.equal("Page")
}

pub fn default_raw_layout_test() {
  let page = layout.Page("/", [], element.none())
  let html =
    layout.default_raw(page, "<main><h1>Raw page</h1></main>")
    |> element.to_document_string()

  assert string.contains(html, "<title>Peter Saxton</title>")
  assert string.contains(html, "<main><h1>Raw page</h1></main>")
  assert string.contains(html, "https://crowdhailer.me/")
  assert !string.contains(html, "<div><main>")
}

pub fn article_layout_test() {
  let metadata = [
    #("title", "An article"),
    #("abstract", "Its abstract"),
    #("share_image", "/share.png"),
    #("share_alt", "Share image"),
  ]
  let page = layout.Page("/article/", metadata, h.p([], [h.text("Body")]))
  let html = layout.article(page) |> element.to_document_string()

  assert string.contains(html, "<main class=\"article\">")
  assert string.contains(html, "<h1>An article</h1><p>Body</p>")
  assert string.contains(
    html,
    "content=\"https://crowdhailer.me/share.png\" property=\"og:image\"",
  )
  assert string.contains(html, "All progress is reported")
}

pub fn article_raw_does_not_wrap_content_test() {
  let page =
    layout.Page("/article/", [#("title", "An article")], element.none())
  let html =
    layout.article_raw(page, "<section>Unchanged HTML</section>")
    |> element.to_document_string()

  assert string.contains(html, "<section>Unchanged HTML</section>")
  assert !string.contains(html, "<div><section>")
}
