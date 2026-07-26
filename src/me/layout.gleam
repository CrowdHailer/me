import gleam/list
import gleam/result
import gleam/string
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h

pub const site_url = "https://crowdhailer.me"

pub const site_title = "Peter Saxton"

pub const site_author = "Peter Saxton"

pub const site_abstract = "Some thoughts and opinions from Peter Saxton"

pub type Page(msg) {
  Page(url: String, metadata: List(#(String, String)), content: Element(msg))
}

pub fn default(page: Page(msg), body: Element(msg)) -> Element(msg) {
  h.html([a.attribute("lang", "en")], [head(page), body])
}

pub fn default_raw(page: Page(msg), content: String) -> Element(msg) {
  default(
    page,
    element.unsafe_raw_html(
      "",
      "body",
      [],
      content <> element.to_string(default_assets()),
    ),
  )
}

pub fn default_body(content: Element(msg)) -> Element(msg) {
  h.body([], [content, default_assets()])
}

fn default_assets() -> Element(msg) {
  element.fragment([
    h.link([
      a.href("/assets/prism.css"),
      a.attribute("rel", "stylesheet"),
    ]),
    h.script([a.src("/assets/prism.js")], ""),
    h.script([a.src("https://unpkg.com/prismjs-gleam@1/gleam.js")], ""),
  ])
}

pub fn article(page: Page(msg)) -> Element(msg) {
  let title = metadata(page.metadata, "title", site_title)
  let image = metadata(page.metadata, "share_image", "")
  let alt = metadata(page.metadata, "share_alt", "")

  default(
    page,
    default_body(
      element.fragment([
        h.header([], [
          h.nav([a.style("text-align", "right")], [
            h.a([a.href("/")], [h.text("Home")]),
          ]),
        ]),
        h.main([a.class("article")], [
          h.img([
            a.src(image),
            a.style("max-width", "100%"),
            a.alt(alt),
          ]),
          h.h1([], [h.text(title)]),
          page.content,
          article_footer(),
        ]),
      ]),
    ),
  )
}

pub fn article_raw(page: Page(msg), content: String) -> Element(msg) {
  let title = metadata(page.metadata, "title", site_title)
  let image = metadata(page.metadata, "share_image", "")
  let alt = metadata(page.metadata, "share_alt", "")
  let before =
    element.fragment([
      h.img([a.src(image), a.style("max-width", "100%"), a.alt(alt)]),
      h.h1([], [h.text(title)]),
    ])
  let main =
    element.unsafe_raw_html(
      "",
      "main",
      [a.class("article")],
      element.to_string(before)
        <> content
        <> element.to_string(article_footer()),
    )

  default(page, default_body(element.fragment([article_header(), main])))
}

fn article_header() -> Element(msg) {
  h.header([], [
    h.nav([a.style("text-align", "right")], [
      h.a([a.href("/")], [h.text("Home")]),
    ]),
  ])
}

fn article_footer() -> Element(msg) {
  element.fragment([
    h.hr([a.style("margin", "2em 0 1em 0")]),
    h.text("I'm building "),
    h.a([a.href("https://eyg.run")], [h.text("EYG")]),
    h.text(
      " an experiment in a building better languages and tools; for some measure of better. ",
    ),
    h.br([]),
    h.text("All progress is reported in my irregular newsletter."),
    h.div(
      [
        a.style("margin", "1em auto"),
        a.style("max-width", "600px"),
      ],
      [
        h.script(
          [
            a.attribute("async", ""),
            a.src(
              "https://eocampaign1.com/form/b3a478b8-39e2-11ef-97b9-955caf3f5f36.js",
            ),
            a.attribute("data-form", "b3a478b8-39e2-11ef-97b9-955caf3f5f36"),
          ],
          "",
        ),
      ],
    ),
  ])
}

fn head(page: Page(msg)) -> Element(msg) {
  let title = metadata(page.metadata, "title", site_title)
  let description = metadata(page.metadata, "abstract", site_abstract)
  let author = metadata(page.metadata, "author", site_author)
  let share_image = absolute_url(metadata(page.metadata, "share_image", ""))
  let share_video = absolute_url(metadata(page.metadata, "share_video", ""))
  let share_alt = metadata(page.metadata, "share_alt", "")

  h.head([], [
    h.meta([a.attribute("charset", "utf-8")]),
    h.meta([
      a.name("viewport"),
      a.content("width=device-width, initial-scale=1.0"),
    ]),
    h.meta([
      a.attribute("http-equiv", "X-UA-Compatible"),
      a.content("ie=edge"),
    ]),
    h.title([], title),
    h.meta([a.name("description"), a.content(description)]),
    h.meta([a.name("author"), a.content(author)]),
    h.script(
      [
        a.attribute("async", ""),
        a.attribute("defer", ""),
        a.attribute("data-domain", "crowdhailer.me"),
        a.src("https://plausible.io/js/plausible.js"),
      ],
      "",
    ),
    h.link([
      a.attribute("rel", "stylesheet"),
      a.href("/assets/site.css"),
      a.attribute("media", "screen"),
      a.attribute("title", "no title"),
      a.attribute("charset", "utf-8"),
    ]),
    property("og:site_name", "crowdhailer.me"),
    property("og:title", title),
    property("og:url", site_url <> page.url),
    property("og:description", description),
    property("og:image", share_image),
    property("og:video", share_video),
    h.meta([a.name("twitter:card"), a.content("summary_large_image")]),
    h.meta([a.name("twitter:image:alt"), a.content(share_alt)]),
    h.meta([a.name("twitter:site"), a.content("@crowdhailer")]),
    h.meta([a.name("twitter:creator"), a.content("@crowdhailer")]),
    h.style([a.attribute("media", "screen")], updates_css),
  ])
}

fn property(name: String, content: String) -> Element(msg) {
  h.meta([a.attribute("property", name), a.content(content)])
}

pub fn metadata(
  values: List(#(String, String)),
  key: String,
  fallback: String,
) -> String {
  list.key_find(values, key) |> result.unwrap(fallback)
}

fn absolute_url(path: String) -> String {
  case path {
    "" -> ""
    _ -> absolute_non_empty_url(path)
  }
}

fn absolute_non_empty_url(path: String) -> String {
  case
    string.starts_with(path, "http://") || string.starts_with(path, "https://")
  {
    True -> path
    False ->
      case string.starts_with(path, "/") {
        True -> site_url <> path
        False -> site_url <> "/" <> path
      }
  }
}

const updates_css = "
    ol.updates {
      list-style: none;
      padding: 0;
    }
    ol.updates h3 {
      font-size: inherit;
      float: left;
      width: 71%;
      padding-top: 0.5em;
      padding-bottom: 0.5em;
    }
    ol.updates aside {
      font-family: monospace;
      text-align: right;

      float: left;
      width: 29%;
      opacity: 0.6;
      padding-top: 0.5em;
      padding-bottom: 0.5em;
      letter-spacing: -0.05em;
    }

    .clearfix:after {
      content: \"\";
      display: table;
      clear: both;
    }
  "
