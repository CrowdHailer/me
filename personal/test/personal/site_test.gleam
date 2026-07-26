import me/build
import personal/site

pub fn build_describes_side_effects_before_running_them_test() {
  let program = site.build(build.context())(build.Done)
  let assert build.EmptyDirectory("public", resume) = program
  let assert build.ReadFile("static/cover.jpg", _) = resume(Ok(Nil))
}

pub fn build_short_circuits_on_effect_error_test() {
  let program = site.build(build.context())(build.Done)
  let assert build.EmptyDirectory("public", resume) = program
  let reason = build.FileError("empty directory", "public", "denied")
  let assert build.Done(Error(found)) = resume(Error(reason))
  assert found == reason
}

pub fn validation_normalizes_a_trailing_reference_slash_test() {
  let program = site.validate(build.context(), "reference/")(build.Done)
  let assert build.ReadDirectory("reference", _) = program
}
