import filepath
import gleam/list
import me/build.{type Context, type Error}
import midas/continuation

pub fn copy_file(context: Context(t), source: String, destination: String) {
  use bits <- continuation.try_then(context.read_file(source))
  context.write_file(destination, bits)
}

pub fn copy_tree(context: Context(t), source: String, destination: String) {
  copy_tree_matching(context, source, destination, fn(_) { True })
}

pub fn copy_tree_matching(
  context: Context(t),
  source: String,
  destination: String,
  should_copy: fn(String) -> Bool,
) {
  use entries <- continuation.try_then(context.read_directory(source))
  use _ <- continuation.try_then(
    continuation.try_each(entries, fn(entry) {
      let source_path = filepath.join(source, entry)
      let destination_path = filepath.join(destination, entry)
      use directory <- continuation.try_then(context.is_directory(source_path))
      case directory, should_copy(source_path) {
        True, _ ->
          copy_tree_matching(
            context,
            source_path,
            destination_path,
            should_copy,
          )
        False, True -> copy_file(context, source_path, destination_path)
        False, False -> continuation.done(Nil)
      }
    }),
  )
  continuation.done(Nil)
}

pub fn collect_files(
  context: Context(t),
  root: String,
) -> continuation.Task(t, List(String), Error) {
  use entries <- continuation.try_then(context.read_directory(root))
  use nested <- continuation.try_then(
    continuation.try_each(entries, fn(entry) {
      let path = filepath.join(root, entry)
      collect_entry(context, path)
    }),
  )
  continuation.done(list.flatten(nested))
}

fn collect_entry(context: Context(t), path: String) {
  use directory <- continuation.try_then(context.is_directory(path))
  case directory {
    True -> collect_files(context, path)
    False -> continuation.done([path])
  }
}
