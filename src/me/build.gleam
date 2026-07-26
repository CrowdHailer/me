import midas/continuation.{type Continuation as K}

pub type Error {
  FileError(operation: String, path: String, reason: String)
  InvalidText(path: String)
  InvalidTemplate(path: String)
  CommandError(reason: String)
}

pub type Context(t) {
  Context(
    empty_directory: fn(String) -> K(t, Result(Nil, Error)),
    is_directory: fn(String) -> K(t, Result(Bool, Error)),
    read_directory: fn(String) -> K(t, Result(List(String), Error)),
    read_file: fn(String) -> K(t, Result(BitArray, Error)),
    write_file: fn(String, BitArray) -> K(t, Result(Nil, Error)),
    run_commands: fn(String) -> K(t, Result(Nil, Error)),
  )
}

pub type Program(a) {
  Done(a)
  EmptyDirectory(String, fn(Result(Nil, Error)) -> Program(a))
  IsDirectory(String, fn(Result(Bool, Error)) -> Program(a))
  ReadDirectory(String, fn(Result(List(String), Error)) -> Program(a))
  ReadFile(String, fn(Result(BitArray, Error)) -> Program(a))
  WriteFile(String, BitArray, fn(Result(Nil, Error)) -> Program(a))
  RunCommands(String, fn(Result(Nil, Error)) -> Program(a))
}

pub fn context() -> Context(Program(a)) {
  Context(
    empty_directory: fn(path) { EmptyDirectory(path, _) },
    is_directory: fn(path) { IsDirectory(path, _) },
    read_directory: fn(path) { ReadDirectory(path, _) },
    read_file: fn(path) { ReadFile(path, _) },
    write_file: fn(path, bytes) { WriteFile(path, bytes, _) },
    run_commands: fn(commands) { RunCommands(commands, _) },
  )
}
