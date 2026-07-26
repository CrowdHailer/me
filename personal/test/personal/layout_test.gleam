import gleam/list
import gleam/string
import lustre/element
import lustre/element/html as h
import personal/gallery
import personal/layout

pub fn home_contains_content_and_navigation_test() {
  let html =
    layout.home(h.p([], [h.text("Home content")]), "body { color: red; }")
    |> element.to_document_string()
  assert string.contains(html, "Home content")
  assert string.contains(html, "href=\"/gallery\"")
  assert string.contains(html, "href=\"/log\"")
  assert string.contains(html, "body { color: red; }")
}

pub fn gallery_has_expected_images_and_widths_test() {
  let html = layout.gallery(gallery.images) |> element.to_document_string()
  assert list.length(gallery.images) == 39
  assert html |> string.split("<img") |> list.length() == 40
  assert html |> string.split("md:w-1/4") |> list.length() == 8
  assert html |> string.split("md:w-1/3") |> list.length() == 33
  assert string.contains(html, "/processed_images/1da72a9faa44d05c00.jpg")
}

pub fn gallery_preserves_deployed_order_test() {
  let filenames =
    gallery.images
    |> list.map(fn(image) {
      let gallery.Image(_, filename, _, _, _) = image
      filename
    })
  assert filenames
    == [
      "1da72a9faa44d05c00.jpg",
      "4a532452d4277bf100.jpg",
      "61e8c1ae5a1b279500.jpg",
      "92a8b0d9ad8e167200.jpg",
      "7e428de0899b041300.jpg",
      "4275c85985bbeea100.jpg",
      "5281ede9f5a49bef00.jpg",
      "99044badeb0bea2a00.jpg",
      "6bb37cfa1f353f7000.jpg",
      "f2d502a64d7e79e800.jpg",
      "c4aecd964963638300.jpg",
      "ba8b8645c58ea24600.jpg",
      "0374a008795a230700.jpg",
      "fcee98537ef6f00400.jpg",
      "20f19c161f30a06300.jpg",
      "09b46d51c6b5dc9600.jpg",
      "9c3c8813a332ddbd00.jpg",
      "9a5d8372bb52310a00.jpg",
      "746cefd6afbcac8100.jpg",
      "d0ad4f904cc7b7c100.jpg",
      "232d61e31a9e897c00.jpg",
      "0404f5efb338ebdd00.jpg",
      "71320d6d4959e14a00.jpg",
      "44d28d85ac677b0c00.jpg",
      "baa186634755c59d00.jpg",
      "f8de849784dc50a300.jpg",
      "dea7cf5bf9d42ee800.jpg",
      "43f6ae4eae4e802100.jpg",
      "45391ec55a356d8000.jpg",
      "99f8d0b8a4b769a400.jpg",
      "947c09844a3de5e900.jpg",
      "cc58e3a2352e2faf00.jpg",
      "38361e6864dee34600.jpg",
      "0bc63b1cdab2551600.jpg",
      "6bfc052c187b61d600.jpg",
      "d2f37a8758c272e300.jpg",
      "d2839d299d63942400.jpg",
      "9d5100b8c9829a8400.jpg",
      "56143ba1a8637a0300.jpg",
    ]
}
