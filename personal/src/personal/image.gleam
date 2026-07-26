import alakazam/image as alakazam_image

pub fn resize_command(
  source: String,
  destination: String,
  width: Int,
  height: Int,
) -> String {
  source
  |> alakazam_image.from_file()
  |> alakazam_image.resize_fill(width, height)
  |> alakazam_image.strip()
  |> alakazam_image.quality(75)
  |> alakazam_image.to_command(destination)
}

pub fn run_all(commands: String) -> Result(Nil, String) {
  case do_run_all(commands) {
    True -> Ok(Nil)
    False -> Error("ImageMagick container failed")
  }
}

@external(javascript, "./image_ffi.mjs", "runAll")
fn do_run_all(commands: String) -> Bool
