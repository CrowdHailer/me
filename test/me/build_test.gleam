import me/build
import me/build/files
import me/site

pub fn context_defunctionalises_file_reads_test() {
  let context = build.context()
  let program = context.read_file("content.html")(build.Done)
  let assert build.ReadFile("content.html", resume) = program
  let assert build.Done(Ok(<<1, 2, 3>>)) = resume(Ok(<<1, 2, 3>>))
}

pub fn copy_file_program_carries_bytes_to_write_test() {
  let program =
    files.copy_file(build.context(), "source.bin", "output/file.bin")(
      build.Done,
    )
  let assert build.ReadFile("source.bin", resume_read) = program
  let assert build.WriteFile("output/file.bin", <<1, 2>>, resume_write) =
    resume_read(Ok(<<1, 2>>))
  let assert build.Done(Ok(Nil)) = resume_write(Ok(Nil))
}

pub fn copy_tree_program_traverses_before_copying_test() {
  let program = files.copy_tree(build.context(), "source", "output")(build.Done)
  let assert build.ReadDirectory("source", resume_directory) = program
  let assert build.IsDirectory("source/file.txt", resume_kind) =
    resume_directory(Ok(["file.txt"]))
  let assert build.ReadFile("source/file.txt", resume_read) =
    resume_kind(Ok(False))
  let assert build.WriteFile("output/file.txt", <<"text":utf8>>, _) =
    resume_read(Ok(<<"text":utf8>>))
}

pub fn site_build_starts_with_clean_output_test() {
  let program = site.build(build.context())(build.Done)
  let assert build.EmptyDirectory("_site", resume) = program
  let assert build.ReadDirectory(".", _) = resume(Ok(Nil))
}

pub fn site_build_stops_after_effect_error_test() {
  let program = site.build(build.context())(build.Done)
  let assert build.EmptyDirectory("_site", resume) = program
  let reason = build.FileError("empty directory", "_site", "denied")
  let assert build.Done(Error(found)) = resume(Error(reason))
  assert found == reason
}
