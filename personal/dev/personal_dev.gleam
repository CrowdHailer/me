import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import me/build
import me/build/runtime
import personal/image
import personal/site

pub fn main() {
  case argv.load().arguments {
    ["build"] -> run_build()
    ["validate", reference] -> run_validation(reference)
    _ -> io.println("Usage: gleam dev build | gleam dev validate <zola-site>")
  }
}

fn run_build() {
  let result =
    site.build(build.context())(build.Done)
    |> runtime.run(image.run_all)
  case result {
    Ok(Nil) -> io.println("Built petersaxton.uk in public/")
    Error(reason) -> panic as string.inspect(reason)
  }
}

fn run_validation(reference) {
  let result =
    site.validate(build.context(), reference)(build.Done)
    |> runtime.run(image.run_all)
  case result {
    Error(reason) -> panic as string.inspect(reason)
    Ok(report) -> {
      print_paths("Missing", report.missing)
      print_paths("Extra", report.extra)
      print_paths("Changed", report.changed)
    }
  }
}

fn print_paths(label, paths) {
  io.println(label <> ": " <> int.to_string(list.length(paths)))
  list.each(paths, fn(path) { io.println("  " <> path) })
}
