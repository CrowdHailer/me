import gleam/list
import lustre/attribute as a
import lustre/element.{type Element}
import lustre/element/html as h
import personal/gallery.{type Image, Image}

pub fn home(content: Element(msg), css: String) -> Element(msg) {
  document(
    [
      h.style([], css),
    ],
    [
      h.header([], [
        h.div([a.class("flex m-4 md:my-10 items-baseline")], [
          h.h1(
            [
              a.class("mr-auto font-serif text-2xl md:text-5xl tracking-widest"),
            ],
            [h.text("Peter Saxton")],
          ),
          navigation("/gallery", "Gallery"),
          navigation("/log", "Log"),
        ]),
        h.img([
          a.class("h-96 object-cover w-full bg-gray-300"),
          a.src("./cover.jpg"),
          a.alt("sunset in Wales"),
        ]),
      ]),
      h.main([a.class("my-4 md:my-10 w-full max-w-5xl mx-auto")], [
        command_indicator(
          "h-2 bg-gradient-to-r from-blue-200 to-gray-800 rounded my-3",
        ),
        h.div([a.class("markdown-body")], [content]),
      ]),
    ],
  )
}

pub fn gallery(images: List(Image)) -> Element(msg) {
  document([], [
    page_header("Peter Saxton"),
    h.main(
      [
        a.class("max-w-6xl my-10 mx-auto flex flex-row flex-wrap"),
      ],
      [h.style([], gallery_css), ..list.map(images, gallery_image)],
    ),
  ])
}

fn gallery_image(image: Image) -> Element(msg) {
  let Image(_, filename, _, _, narrow) = image
  let width = case narrow {
    True -> "md:w-1/4"
    False -> "md:w-1/3"
  }
  h.label([a.class("flex-grow p-px " <> width)], [
    h.input([
      a.class("hidden"),
      a.type_("checkbox"),
      a.name("focus"),
    ]),
    h.img([
      a.class("object-cover min-w-full min-h-full max-h-96 cursor-pointer"),
      a.src("/processed_images/" <> filename),
      a.alt(""),
    ]),
  ])
}

fn navigation(path: String, label: String) -> Element(msg) {
  h.nav([a.class("md:text-lg")], [
    h.a(
      [
        a.class("px-2 py-1 border-gray-300 hover:border-gray-600 border-b-2"),
        a.href(path),
      ],
      [h.text(label)],
    ),
  ])
}

fn page_header(title: String) -> Element(msg) {
  h.header([], [
    h.div([a.class("flex m-4 md:my-10 items-baseline")], [
      h.a([a.class("pointer"), a.href("/")], [
        h.h1(
          [
            a.class("mr-auto font-serif text-2xl md:text-5xl tracking-widest"),
          ],
          [h.text(title)],
        ),
      ]),
      h.nav([a.class("md:text-lg hidden md:block")], []),
    ]),
    command_indicator(
      "max-w-6xl mx-auto h-2 bg-gradient-to-r from-blue-200 to-gray-800 rounded my-3",
    ),
  ])
}

fn command_indicator(classes: String) -> Element(msg) {
  h.div(
    [
      a.id("command"),
      a.style("display", "none"),
      a.class(classes),
    ],
    [],
  )
}

fn document(extra_head: List(Element(msg)), body: List(Element(msg))) {
  h.html([a.attribute("lang", "en")], [
    h.head([], [
      h.meta([a.attribute("charset", "UTF-8")]),
      h.meta([
        a.attribute("http-equiv", "X-UA-Compatible"),
        a.content("IE=edge"),
      ]),
      h.meta([
        a.name("viewport"),
        a.content("width=device-width, initial-scale=1.0"),
      ]),
      h.title([], "Peter Saxton"),
      h.link([
        a.href("https://unpkg.com/tailwindcss@^2/dist/tailwind.min.css"),
        a.attribute("rel", "stylesheet"),
      ]),
      h.script([a.src("/main.js"), a.type_("module")], ""),
      h.script(
        [
          a.attribute("defer", ""),
          a.attribute("data-domain", "petersaxton.uk"),
          a.src("https://plausible.io/js/script.js"),
        ],
        "",
      ),
      ..extra_head
    ]),
    h.body([a.class("text-gray-600 px-4")], body),
  ])
}

const gallery_css = "
label > input:checked + img {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  object-fit: contain;
  background: white;
  padding: 0.25em;
}
"
