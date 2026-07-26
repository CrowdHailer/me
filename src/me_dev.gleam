import argv
import gleam/io
import gleam/string
import me/build
import me/build/runtime
import me/site

pub fn main() {
  case argv.load().arguments {
    ["build"] -> run_build()
    _ -> io.println("Usage: gleam dev build")
  }
}

fn run_build() {
  let result = site.build(build.context())(build.Done) |> runtime.run
  case result {
    Ok(Nil) -> io.println("Built crowdhailer.me in _site/")
    Error(reason) -> panic as string.inspect(reason)
  }
}
