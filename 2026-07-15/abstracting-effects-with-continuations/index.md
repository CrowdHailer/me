---
layout: article
title: Abstracting effects with continuations
abstract: Failures, asynchrony and more can all be represented by continuations
# share_image: /2026-05-11/running-my-agents-in-a-vps/isolated-agents.png
# share_alt: Generated image of AI agents working isolated on a VPS.
---

Representing errors as values is a powerful tool for writing reliable programs.
A result value wraps the desired value or holds information about why the computation failed.
An explicit result type represents the possibility of failure in the type system.
A function that returns a result forces the caller to account for failure.

The result is one instance of a bigger pattern.
A promise represents computation that is asynchronous.
Return a promise and the caller is forced to wait for the computation to complete before accessing the value.

A result and promise each track a specific detail about some computation.
To generalise over the details of a computation, use a continuation.
Using a continuation says: "I have no idea how you're going to get the value, but when you do, this is what should be done next."

Filinski, *Representing Monads* (1994) proves continuations can express any monad (such as Result and Promise).
We will not get into the maths of the proof.
This post is to demonstrate how to use continuations in Gleam.

## A contrived example

We work with a `fetch` function that returns a value for a key.
The function is provided by the caller and takes a `String` key and returns a `String` value.

Accepting `fetch` as an argument allows us to fetch values from different data sources as needed.
A trivial implementation of `fetch` could ignore the key and always return `"yes"`:

```gleam
fn fetch(key: String) -> String {
  "yes"
}
```

The business logic does the following.
For a fixed list of keys, transform each to uppercase, and return the length of the associated value.
A simple solution to this task looks like the following.

```gleam
pub fn simple_func(fetch: fn(String) -> String) -> List(Int) {
  let keys = ["a", " b"]
  list.map(keys, fn(key) {
    let key = string.uppercase(key)
    let value = fetch(key)
    string.length(value)
  })
}
```

## Moving into enterprise

Our `simple_func` is working very well, so the business looks to expand.
The business logic remains the same but our enterprise customers keep their data in all sorts of storage.
Some fetch implementations can't always return a value.
To handle this we create a new version of our business logic where `fetch` returns a `Result(String, Nil)`.

```gleam
pub fn fallible_func(fetch: fn(String) -> Result(String, Nil)) -> Result(List(Int), Nil) {
  let keys = ["a", " b"]
  list.try_map(keys, fn(key) {
    let key = string.uppercase(key)
    use value <- result.map(fetch(key))
    string.length(value)
  })
}
```

There is great success with the new function and soon after a request for an asynchronous data store arrives.
Another implementation that accepts a fetch that returns `Promise(String)` solves this.

```gleam
pub fn async_func(fetch: fn(String) -> Promise(String)) -> Promise(List(Int)) {
  let keys = ["a", "b"]
  list.map(keys, fn(key) {
    let key = string.uppercase(key)
    use value <- promise.map(fetch(key))
    string.length(value)
  })
  |> promise.await_list
}
```

At this point we have three implementations to support all the different requirements.
In each version, the business logic is the same and the functions are similar.
But we are not reusing the business logic between implementations.

Even worse, the requirement for a fallible and async implementation, a fetch that returns `Promise(Result(String, Nil))` is waiting for us.
We cannot reuse the fallible or async implementation and will require a fourth implementation of our function.

## The missing abstraction

All that changes between implementations is what kind of computation `fetch` performs: direct, fallible, asynchronous or something else.
The common part of each implementation is how to create a key and what to do with the value if/when it is available.

A continuation allows us to represent this "before and after" relationship while being generic over the kind of computation happening.

```gleam
pub type Continuation(t, a) =
  fn(fn(a) -> t) -> t
```

The type of value our continuation wraps is `a`.
The (as yet unspecified) details of the computation are `t`.

We create a new version accepting a `fetch` that returns a `Continuation(t, String)`.

```gleam
import midas/continuation.{type Continuation as K}

pub fn task(fetch: fn(String) -> K(t, String)) -> K(t, List(Int)) {
  let keys = ["a", "b"]
  continuation.each(keys, fn(key) {
    let key = string.uppercase(key)
    use value <- continuation.then(fetch(key))
    continuation.return(string.length(value))
  })
}
```

This task is now generic over the kind of computation.
The caller will choose the concrete type of `t` through the implementation of `fetch` it provides.
To extract the final value, the caller will need to provide a final callback.
A caller for a continuation based task is often called a runner or interpreter.

### Simple runner

In the simple case `fetch` has no extra effects and it always resumes with a string.
It still returns a continuation, so the final value is wrapped with `continuation.return`.
Because the final value is unwrapped, the identity function is passed as the final callback.

This simple runner returns a `List(Int)` reflecting that `fetch` itself is infallible and synchronous.

```gleam
import midas/continuation

fn run_simple(task) -> List(Int) {
  let fetch = fn(_key) { continuation.return("yes") }

  task(fetch)(fn(x) { x })
}

fn run_simple_test() {
  let assert [3, 3] = run_simple(task)
}
```

### Fallible runner

In the case where `fetch` returns a `Result(String, Nil)`, our final callback must also return a result.
Therefore the final callback wraps the value with `Ok`.

`then` is the callback that resumes the task, which is called with the value (if it exists).

```gleam
fn run_fallible(keys, task) -> Result(List(Int), Nil) {
  let fetch = fn(key) {
    fn(then) {
      case dict.get(keys, key) {
        Ok(value) -> then(value)
        Error(Nil) -> Error(Nil)
      }
    }
  }

  task(fetch)(Ok)
}

fn run_fallible_test() {
  let assert Error(Nil) =
    run_fallible(dict.from_list([#("A", "Apple")]), task)

  let assert Ok([5, 6]) =
    run_fallible(dict.from_list([#("A", "Apple"), #("B", "Banana")]), task)
}
```

### Async runner

When `fetch` is asynchronous, the runner chooses `t` to be `Promise(List(Int))`.
The final callback uses `promise.resolve` to match `t`.

```gleam
fn run_async(task) {
  let fetch = fn(_key) {
    fn(then) {
      use Nil <- promise.await(promise.wait(100))
      then("slow")
    }
  }

  task(fetch)(promise.resolve)
}

fn run_async_test() {
  use v <- promise.await(task |> run_async())
  // [slow, slow]
  let assert [4, 4] = v

}
```

### Conclusion

With `task` we have a single definition of our business logic.
It describes how values should be used regardless of how they are fetched.

A runner decides how values are fetched.
Any task written in this style can use the same runner.
This separation of logic and effects is the abstraction continuations give us.
