import gleam/list

pub type Step(a) {
  Done(a)
  Next(fn() -> Step(a))
}

pub fn run(step: Step(a)) -> a {
  case step {
    Done(value) -> value
    Next(next) -> run(next())
  }
}

fn even(n: Int) -> Step(Bool) {
  case n {
    0 -> Done(True)
    _ -> Next(fn() { odd(n - 1) })
  }
}

fn odd(n: Int) -> Step(Bool) {
  case n {
    0 -> Done(False)
    _ -> Next(fn() { even(n - 1) })
  }
}

pub type Program(t, a) =
  fn(fn(a) -> Step(t)) -> Step(t)

pub fn return(value: a) -> Program(t, a) {
  fn(finish) { Next(fn() { finish(value) }) }
}

pub fn then(
  program: Program(t, a),
  next: fn(a) -> Program(t, b),
) -> Program(t, b) {
  fn(finish) {
    Next(fn() { program(fn(value) { Next(fn() { next(value)(finish) }) }) })
  }
}

pub fn defer(build: fn() -> Program(t, a)) -> Program(t, a) {
  fn(finish) { Next(fn() { build()(finish) }) }
}

pub fn map_program(
  program: Program(t, a),
  transform: fn(a) -> b,
) -> Program(t, b) {
  fn(finish) {
    Next(fn() { program(fn(value) { Next(fn() { finish(transform(value)) }) }) })
  }
}

fn nested(n) -> Program(t, Int) {
  case n {
    0 -> return(0)
    _ -> defer(fn() { map_program(nested(n - 1), fn(n) { n + 1 }) })
  }
}

pub fn main() {
  assert run(even(1_000_000))
  assert !run(even(1_000_001))
  let increments = list.repeat(Nil, 50_000)
  let composed =
    list.fold(increments, return(0), fn(program, _) {
      use n <- then(program)
      return(n + 1)
    })
  assert run(composed(Done)) == 50_000
  let mapped =
    list.fold(increments, return(0), fn(program, _) {
      map_program(program, fn(n) { n + 1 })
    })
  assert run(mapped(Done)) == 50_000
  assert run(nested(50_000)(Done)) == 50_000
}
