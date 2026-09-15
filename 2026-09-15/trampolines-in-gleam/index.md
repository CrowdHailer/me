---
layout: article
title: Trampolines in Gleam
abstract: Returning the next computation instead of calling it makes continuation-heavy code stack-safe on JavaScript.
---

In [Abstracting effects with continuations](/2026-07-15/abstracting-effects-with-continuations/)
I used continuations to keep a computation independent of its effects.
There is a runtime detail that the types do not tell us: calling a continuation
can consume the host's call stack.

This showed up while adding presentation callbacks to Pamphlet, a document renderer.
The renderer walks a document, resolves references, tracks footnotes, and asks the
application how each element should look.
Those callbacks made it easy to add syntax highlighting.
They also added enough calls per node for a fairly small document to overflow
the stack on Node.

The document was not unusually deep.
Each callback called the rest of the render before returning, so the execution
chain grew with the amount of content.

Gleam turns direct self-tail-recursion into a loop when compiling to JavaScript.
That does not provide general tail-call elimination across arbitrary callbacks.
Writing in CPS does not, by itself, make that execution stack-safe.

## Return the next call

A trampoline moves the transfer to the next computation out of the host stack.
A step either contains a result or describes another step to execute:

```gleam
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
```

The runner is direct self-tail-recursion, so Gleam can compile it into a loop.
The important invariant is that `next()` returns a step to that loop **before
the following step executes**.

Instead of calling `f(value)`, return `Next(fn() { f(value) })`.
The closure captures the state needed to resume, and the current host frames can
be discarded.

Here is a deliberately small example involving two functions:

```gleam
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
```

For non-negative inputs, `run(even(1_000_000))` executes a million transfers
without a million live call frames.
Each function returns to the driver rather than directly entering the other.

This bounds the host stack, not all memory use.
Pending work still occupies heap objects and closures.
It also does not imply asynchronous execution: this runner stays on the current
thread until the computation finishes.

## Suspending continuations

A direct continuation has the familiar type:

```gleam
pub type Continuation(t, a) =
  fn(fn(a) -> t) -> t
```

For stack-safe execution, let it return a suspended final answer:

```gleam
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
    Next(fn() {
      program(fn(value) { Next(fn() { next(value)(finish) }) })
    })
  }
}
```

There are two suspension points in `then`.
The outer `Next` prevents a long, left-associated composition from recursively
entering all its earlier computations.
The inner `Next` prevents the forward continuation chain from running without
returning to the driver.

At the boundary, supply `Done` as the final continuation and run the resulting
step: `run(program(Done))`.

## Construction can recurse too

Suspending execution is not enough if constructing the computation traverses the
whole tree first.
An eager recursive builder can overflow before `run` is called.
Delay the construction itself:

```gleam
pub fn defer(build: fn() -> Program(t, a)) -> Program(t, a) {
  fn(finish) { Next(fn() { build()(finish) }) }
}
```

Pamphlet needs this at recursive node boundaries.
A deeply nested inline node must produce suspended work before it constructs the
program for its child.

The same invariant applies everywhere: every potentially unbounded chain must
cross a point that returns control to the driver.
Merely wrapping a recursive result in `Next` does not make the recursive call
used to obtain that result safe.

## Keep the return path in the protocol

A callback may also transform the final answer after continuing.
With ordinary continuations, it can call `next(value)`, inspect the returned
answer, and change it.
With suspended execution, the answer is not available yet.

One way to represent that dependency is to keep the answer-producing computation
in CPS as well, and compose a new final continuation:

```gleam
pub fn map_program(
  program: Program(t, a),
  transform: fn(a) -> b,
) -> Program(t, b) {
  fn(finish) {
    Next(fn() {
      program(fn(value) { Next(fn() { finish(transform(value)) }) })
    })
  }
}
```

Both descent through composed programs and transfer through their continuations
return suspended steps.
The step type still only needs `Done` and `Next`.

A tempting alternative is a recursive map over `Step`: on `Next(next)`, return
another thunk that maps `next()`.
One such wrapper is harmless, but a tower of wrappers can recursively force each
other before any returns to the runner.
Calling a nested `run` from every callback has a similar problem.
The placement of suspension boundaries matters more than the constructor names.

## What it costs

Trampolines exchange host-stack usage for heap allocation and interpreter dispatch.
They are an execution strategy, not a throughput optimisation.
It is worth measuring renderer construction, traversal, and serialization
separately: parsing can hide a substantial relative change in traversal cost.

For Pamphlet I keep the presentation API separate from the stack experiment.
The API branch uses direct continuations and documents the limitation.
The experiment has checks for 20,000 callbacks, deeply nested nodes, a late halt,
and transformations of the final answer.
The parser, the HTML serializer, and recursive code inside user callbacks still
have their own stack behaviour.

An explicit traversal machine is another option.
Instead of capturing “finish this paragraph after these children” in a closure,
store a `BuildParagraph` frame alongside `VisitNode` instructions and interpret
that work list in a loop.
That can specialise dispatch and reduce closure allocation, but requires a larger
traversal rewrite.
General callback control flow still needs an explicit execution contract.

For the current design, `Done` and `Next` make the missing boundary small and
visible: the rest of the computation is a value until the runner executes it.

The [complete example](example/src/trampoline_article.gleam) includes million-step
mutual recursion and 50,000 composed programs. From the accompanying
[Gleam package](example/gleam.toml), run `gleam run --target javascript` to check it
on Node, or `gleam run` for the BEAM.
