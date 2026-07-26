import gleam/list
import personal/gallery
import personal/image

pub fn alakazam_resize_pipeline_test() {
  assert image.resize_command("input.jpg", "output.jpg", 900, 588)
    == "magick input.jpg -resize 900x588! -strip -quality 75 output.jpg"
}

pub fn zola_edge_dimensions_are_in_manifest_test() {
  assert list.contains(
    gallery.images,
    gallery.Image("2021-06-18.jpg", "20f19c161f30a06300.jpg", 900, 588, False),
  )
  assert list.contains(
    gallery.images,
    gallery.Image("2020-11-21.jpg", "ba8b8645c58ea24600.jpg", 900, 639, False),
  )
  assert list.contains(
    gallery.images,
    gallery.Image("2020-08-15.jpg", "6bfc052c187b61d600.jpg", 900, 770, True),
  )
  assert list.contains(
    gallery.images,
    gallery.Image("2021-07-23.jpg", "9a5d8372bb52310a00.jpg", 900, 675, False),
  )
}
