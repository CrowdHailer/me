import filepath
import gleam/list
import gleam/result
import me/build.{type Error, type Program}
import simplifile

pub fn run(program: Program(a)) -> a {
  case program {
    build.Done(value) -> value
    build.EmptyDirectory(path, resume) -> run(resume(empty_directory(path)))
    build.IsDirectory(path, resume) ->
      run(resume(
        simplifile.is_directory(path)
        |> file_result("inspect directory", path),
      ))
    build.ReadDirectory(path, resume) ->
      run(resume(
        simplifile.read_directory(path)
        |> file_result("read directory", path),
      ))
    build.ReadFile(path, resume) ->
      run(resume(
        simplifile.read_bits(path)
        |> file_result("read file", path),
      ))
    build.WriteFile(path, bytes, resume) -> {
      let result = {
        use Nil <- result.try(
          simplifile.create_directory_all(filepath.directory_name(path)),
        )
        simplifile.write_bits(path, bytes)
      }
      run(resume(file_result(result, "write file", path)))
    }
  }
}

fn empty_directory(path: String) -> Result(Nil, Error) {
  case simplifile.read_directory(path) {
    Ok(entries) ->
      entries
      |> list.map(filepath.join(path, _))
      |> simplifile.delete_all()
      |> file_result("empty directory", path)
    Error(simplifile.Enoent) ->
      simplifile.create_directory_all(path)
      |> file_result("create directory", path)
    Error(reason) -> Error(file_error("read directory", path, reason))
  }
}

fn file_result(result, operation, path) {
  result |> result.map_error(file_error(operation, path, _))
}

fn file_error(operation, path, reason) {
  build.FileError(operation, path, simplifile.describe_error(reason))
}
