import me/path

pub fn markdown_index_output_test() {
  assert path.output_path("_site", "post/index.md") == "_site/post/index.html"
}

pub fn html_output_is_unchanged_test() {
  assert path.output_path("_site", "talk/slides.html")
    == "_site/talk/slides.html"
}

pub fn root_page_url_test() {
  assert path.page_url("_site", "_site/index.html") == "/"
}

pub fn directory_page_url_test() {
  assert path.page_url("_site", "_site/post/index.html") == "/post/"
}

pub fn file_page_url_test() {
  assert path.page_url("_site", "_site/feed.xml") == "/feed.xml"
}

pub fn strip_root_only_removes_prefix_test() {
  assert path.strip_root("content/post/index.md", "content") == "post/index.md"
  assert path.strip_root("other/post/index.md", "content")
    == "other/post/index.md"
}

pub fn hidden_file_test() {
  assert path.is_hidden("images/.comments/file.xml")
  assert !path.is_hidden("images/photo.jpg")
}
