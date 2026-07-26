import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import me/build
import me/build/runtime
import me/site

pub fn main() {
  case argv.load().arguments {
    ["build"] -> run_build()
    ["validate", reference] -> run_validation(reference)
    _ -> io.println("Usage: gleam dev build | gleam dev validate <jekyll-site>")
  }
}

fn run_build() {
  let result =
    site.build(build.context())(build.Done) |> runtime.run(no_commands)
  case result {
    Ok(Nil) -> io.println("Built crowdhailer.me in _site/")
    Error(reason) -> panic as string.inspect(reason)
  }
}

fn run_validation(reference) {
  let result =
    site.validate(build.context(), reference)(build.Done)
    |> runtime.run(no_commands)
  case result {
    Error(reason) -> panic as string.inspect(reason)
    Ok(report) -> {
      io.println("Reference files: " <> int.to_string(report.expected_count))
      io.println("Generated files: " <> int.to_string(report.actual_count))
      print_paths("Missing", report.missing)
      print_paths("Extra", report.extra)
      print_paths("Changed", report.changed)
      let unexpected_changes =
        list.filter(report.changed, fn(path) {
          path != "README.md" && !list.contains(report.generated, path)
        })
      case report.missing, report.extra, unexpected_changes {
        [], [], [] -> Nil
        _, _, _ -> panic as "Bundle validation failed"
      }
    }
  }
}

fn no_commands(_) {
  Error("This build does not support process commands")
}

fn print_paths(label, paths) {
  io.println(label <> ": " <> int.to_string(list.length(paths)))
  list.each(paths, fn(path) { io.println("  " <> path) })
}
