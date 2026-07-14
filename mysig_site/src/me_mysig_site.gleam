import filepath
import gleam/io
import gleam/list
import gleam/string
import lustre/attribute as a
import lustre/element
import lustre/element/html as h
import mysig/ssg.{type CollectionPage}
import simplifile
import snag.{type Snag}

const root_output = "public/crowdhailer.me"

const personal_output = "public/petersaxton.uk"

pub fn main() {
  let assert Ok(Nil) = build_root_site()
  let assert Ok(Nil) = build_personal_site()
  io.println("Built both sites into mysig_site/public")
}

fn build_root_site() -> Result(Nil, Snag) {
  use Nil <- result_try(create_directory(root_output))
  use html_files <- result_try(ssg.collect_files_excluding(
    "..",
    ["html"],
    excluded_root_directories(),
  ))
  use Nil <- result_try(copy_files(html_files, "..", root_output))

  use static_files <- result_try(
    ssg.collect_files_excluding("../assets", [], []),
  )
  use Nil <- result_try(copy_files(static_files, "..", root_output))

  use markdown_paths <- result_try(ssg.collect_files_excluding(
    "..",
    ["md"],
    excluded_root_directories(),
  ))
  let markdown =
    list.map(public_root_markdown(markdown_paths), fn(path) {
      ssg.Entry(
        path: path,
        output_path: filepath.join(root_output, html_path(ssg_path(path, ".."))),
      )
    })
  use rendered <- result_try(ssg.render_collection(
    markdown,
    root_article_layout,
  ))
  write_files(rendered)
}

fn build_personal_site() -> Result(Nil, Snag) {
  use Nil <- result_try(create_directory(personal_output))
  use static_files <- result_try(ssg.collect_files("../personal/static", []))
  use Nil <- result_try(copy_files(
    static_files,
    "../personal/static",
    personal_output,
  ))
  use gallery <- result_try(
    ssg.collect_files("../personal/content/gallery", ["jpg", "png"]),
  )
  use Nil <- result_try(copy_files(
    gallery,
    "../personal/content",
    personal_output,
  ))

  let index = personal_home()
  use Nil <- result_try(write_text(
    filepath.join(personal_output, "index.html"),
    index,
  ))
  use Nil <- result_try(write_text(
    filepath.join(personal_output, "gallery/index.html"),
    personal_gallery(gallery),
  ))
  write_text(filepath.join(personal_output, "log/index.html"), personal_log())
}

fn root_article_layout(page: CollectionPage(msg)) {
  let title = metadata(page.metadata, "title", "Peter Saxton")
  let abstract = metadata(page.metadata, "abstract", "Peter Saxton")
  let share_image = metadata(page.metadata, "share_image", "")
  let share_alt = metadata(page.metadata, "share_alt", "")

  h.html([a.attribute("lang", "en")], [
    h.head([], [
      h.meta([a.attribute("charset", "utf-8")]),
      h.meta([
        a.name("viewport"),
        a.content("width=device-width, initial-scale=1.0"),
      ]),
      h.title([], title),
      h.meta([a.name("description"), a.content(abstract)]),
      h.link([a.rel("stylesheet"), a.href("/assets/site.css")]),
      h.script(
        [
          a.attribute("async", ""),
          a.attribute("defer", ""),
          a.attribute("data-domain", "crowdhailer.me"),
          a.src("https://plausible.io/js/plausible.js"),
        ],
        "",
      ),
    ]),
    h.body([], [
      h.header([], [
        h.nav([a.style("text-align", "right")], [
          h.a([a.href("/")], [element.text("Home")]),
        ]),
      ]),
      h.main([a.class("article")], [
        h.img([
          a.src(share_image),
          a.alt(share_alt),
          a.style("max-width", "100%"),
        ]),
        h.h1([], [element.text(title)]),
        page.content,
        h.hr([a.style("margin", "2em 0 1em 0")]),
        element.text("I'm building "),
        h.a([a.href("https://eyg.run")], [element.text("EYG")]),
        element.text(" an experiment in building better languages and tools."),
      ]),
      h.link([a.href("/assets/prism.css"), a.rel("stylesheet")]),
      h.script([a.src("/assets/prism.js")], ""),
      h.script([a.src("https://unpkg.com/prismjs-gleam@1/gleam.js")], ""),
    ]),
  ])
}

fn personal_home() {
  personal_shell("Peter Saxton", [
    h.section([a.class("max-w-4xl my-10 mx-auto markdown-body")], [
      h.h1([], [element.text("Peter Saxton")]),
      h.p([], [element.text("Personal site migrated to Mysig SSG.")]),
      h.ul([], [
        h.li([], [h.a([a.href("/gallery/")], [element.text("Gallery")])]),
        h.li([], [h.a([a.href("/log/")], [element.text("Log")])]),
      ]),
    ]),
  ])
}

fn personal_gallery(images: List(String)) {
  let items =
    images
    |> list.map(fn(path) {
      let src = "/" <> ssg_path(path, "../personal/content")
      h.label([a.class("flex-grow p-px md:w-1/4")], [
        h.input([a.class("hidden"), a.type_("checkbox"), a.name("focus")]),
        h.img([
          a.class("object-cover min-w-full min-h-full max-h-96 cursor-pointer"),
          a.src(src),
        ]),
      ])
    })

  personal_shell("Peter Saxton Gallery", [
    h.main([a.class("max-w-6xl my-10 mx-auto flex flex-row flex-wrap")], items),
  ])
}

fn personal_log() {
  personal_shell("Peter Saxton Log", [
    h.main([a.class("max-w-4xl my-10 mx-auto")], [
      h.h1([], [element.text("Log")]),
      h.p([], [
        element.text(
          "The original embedded video log is preserved as migration follow-up content.",
        ),
      ]),
    ]),
  ])
}

fn personal_shell(title, children) {
  h.html([a.attribute("lang", "en")], [
    h.head([], [
      h.meta([a.attribute("charset", "UTF-8")]),
      h.meta([
        a.name("viewport"),
        a.content("width=device-width, initial-scale=1.0"),
      ]),
      h.title([], title),
      h.link([
        a.href("https://unpkg.com/tailwindcss@^2/dist/tailwind.min.css"),
        a.rel("stylesheet"),
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
    ]),
    h.body([a.class("text-gray-600 px-4")], children),
  ])
  |> element.to_document_string()
}

fn metadata(metadata, key, default) {
  case list.key_find(metadata, key) {
    Ok(value) -> value
    Error(Nil) -> default
  }
}

fn excluded_root_directories() {
  [".git", ".jekyll-cache", "_layouts", "_site", "mysig_site", "personal"]
}

fn public_root_markdown(paths: List(String)) {
  list.filter(paths, fn(path) {
    path != "../README.md" && path != "../mysig-migration-plan.md"
  })
}

fn copy_files(
  paths: List(String),
  root: String,
  output_root: String,
) -> Result(Nil, Snag) {
  case paths {
    [] -> Ok(Nil)
    [path, ..rest] -> {
      use bytes <- result_try(read_bits(path))
      let output = filepath.join(output_root, ssg_path(path, root))
      use Nil <- result_try(create_directory(filepath.directory_name(output)))
      use Nil <- result_try(write_bits(output, bytes))
      copy_files(rest, root, output_root)
    }
  }
}

fn write_files(files) {
  case files {
    [] -> Ok(Nil)
    [#(path, bytes), ..rest] -> {
      use Nil <- result_try(create_directory(filepath.directory_name(path)))
      use Nil <- result_try(write_bits(path, bytes))
      write_files(rest)
    }
  }
}

fn ssg_path(path: String, root: String) {
  let prefix = root <> "/"
  string.drop_start(path, string.length(prefix))
}

fn html_path(path: String) {
  case string.ends_with(path, "/index.md"), string.ends_with(path, ".md") {
    True, _ -> string.drop_end(path, 3) <> ".html"
    _, True -> string.drop_end(path, 3) <> "/index.html"
    _, False -> path <> "/index.html"
  }
}

fn read_bits(path: String) -> Result(BitArray, Snag) {
  case simplifile.read_bits(path) {
    Ok(bytes) -> Ok(bytes)
    Error(reason) -> snag.error(simplifile.describe_error(reason))
  }
}

fn write_bits(path: String, bytes: BitArray) -> Result(Nil, Snag) {
  case simplifile.write_bits(path, bytes) {
    Ok(Nil) -> Ok(Nil)
    Error(reason) -> snag.error(simplifile.describe_error(reason))
  }
}

fn write_text(path: String, text: String) -> Result(Nil, Snag) {
  write_bits(path, <<text:utf8>>)
}

fn create_directory(path: String) -> Result(Nil, Snag) {
  case simplifile.create_directory_all(path) {
    Ok(Nil) -> Ok(Nil)
    Error(reason) -> snag.error(simplifile.describe_error(reason))
  }
}

fn result_try(
  result: Result(a, e),
  next: fn(a) -> Result(b, e),
) -> Result(b, e) {
  case result {
    Ok(value) -> next(value)
    Error(reason) -> Error(reason)
  }
}
