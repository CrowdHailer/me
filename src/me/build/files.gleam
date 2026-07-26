import me/build.{type Context}
import midas/continuation

pub fn copy_file(context: Context(t), source: String, destination: String) {
  use bits <- continuation.try_then(context.read_file(source))
  context.write_file(destination, bits)
}
