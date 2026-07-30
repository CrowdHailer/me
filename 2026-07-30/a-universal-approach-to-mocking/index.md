---
layout: article
title: A universal approach to mocking
abstract: Defunctionalise your continuations and your tests can run any computation a step at a time.
---

## Building on continuations

I recently wrote about how to abstract code that might run synchronously or asynchronously and with or without the possibility of errors.
The abstraction introduced was continuations and [it is proven](https://dl.acm.org/doi/10.1145/174675.178047) that continuations can represent any monadic computation.

In this post I show how we can defunctionalise the continuations to a single data type that makes for clean and effective testing.

For a refresher on continuations in Gleam check out [the previous post](/2026-07-15/abstracting-effects-with-continuations/).
In that post we ended up with the following business logic function.

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

For each shape of computation (each reification of `t`) we implement a runner.
So there was a runner for fallible computation, where `t` was a `Result`, and another for asynchronous, where `t` was a `Promise`.

## Testing requirements

Testing our implementation of `task` needs to check:

1. That `fetch` is called with the correct arguments.
2. That the return from `fetch` is processed correctly. 

We are injecting a value of fetch so we can provide a dummy value and use that in our testing.

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

This is ok, but not great.
First up we aren't testing that the key is correct.
Second because we always return the same value we aren't testing with different length values.
Maybe our implementation returns the list reversed and we would never know.

Is better mocking the solution?

```gleam
import midas/continuation

fn run_simple(task) -> List(Int) {
  let fetch = fn(key) { 
    let value = case key {
      "A" -> "apple"
      "B" -> "banana"
      _ -> panic as "unexpected key"
    }
    continuation.return(value)
  }

  task(fetch)(fn(x) { x })
}

fn run_simple_test() {
  let assert [5, 6] = run_simple(task)
}
```

This is a more sophisticated version of `fetch`.
It returns different length values and breaks our test for the wrong key.
But it's not perfect, it still doesn't assert that the effects are called in the right order.

The logic in `fetch` is growing and we need to write a new mock for each test.
The distance between an implementation and assertion is also growing.
To check that the value `6` is correct you need to go up to the declaration of the string `"banana"`.
For larger tests and mocks this distance only increases.

## Capture effects instead of performing them

The trick to improve our testing is to realise that fetch doesn't need to call our continuation at all.
Instead we can create a new type `Effect` that captures a call to `fetch` returning both the key and resume function to the caller.
In this case the caller will be the test.

This is clearest to see from the implementation.

```gleam
import midas/continuation.{type Continuation as K}

pub type Effect(r) {
  Fetch(key: String, resume: fn(String) -> Effect(r))
  Pure(value: r)
}

pub fn fetch(key: String) -> K(Effect(t), String) {
  fn(resume) { Fetch(key, resume) }
}

fn run_capture(task) -> Effect(_) {
  task(fetch)(Pure)
}
```

The type `Effect` has variants for each effect our task might use and a final variant `Pure` for when the task has finished.
In this example the only effect variant is `Fetch`.
Supporting a new effect in `task` is as simple as adding a new variant to `Effect`.

The implementation of `fetch` just builds an `Effect` type, it does not call resume.

## Tests drive the computation

Let's rewrite the task test using this runner.

```gleam
fn capture_test() {
  let assert Fetch("A", resume) = run_capture(task)
  let assert Fetch("B", resume) = resume("apple")
  let assert Pure([5, 6]) = resume("banana")
}
```

This is much clearer and has several benefits

- There is no test specific mock, the implementation of `fetch` is shared across all tests.
- Order of calls is checked, we check `fetch` is first called with `A` and then a second time with `B`.
- We assert there are no extra effectful calls.
- Resume values are close to assertions, `"apple"` and `"banana"` are defined in the test, not the mock.

## Conclusion

I like this approach because it works the same way for every effect.
The downside is it forces continuations everywhere you have effectful code.
A quick side note: I still try to keep my core logic pure and effects at the edges of my system.
So for much of the code there is no change.

I'm also mostly building on the JavaScript runtime so replacing promises, which there is no way to avoid, with continuations is not much of a cost.

In return I get a clean approach to testing because of everything it doesn't contain.
I have no mocking library, no stub objects, no dependency injection framework, no async test runner.
