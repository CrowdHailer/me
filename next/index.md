
# POST 2 Uncolour your function

## What is function colouring

Function colouring is the observation, from Bob Nystrom's 2015 article What Color is Your Function?, that asynchrony is contagious.
A function that awaits a promise must itself return a promise, so its callers must also await and return promises.

This colouring aflicts code that might be used asynchronously, even if a given use case is totally synchronous.

In my previous post on continuations I introduced the same program in three different flavours simple, fallible and asynchronous.
Below is the asynchronous version

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

It is impossible to use `async_func` synchronously, even if we have a synchronous version of `fetch` to pass in.
The implementation commits only work on the promise type.

## Gleam and multiple runtimes.

Gleam feels the function colouring problem more acutely than many languages, because a Gleam module can compile to two different targets.
On the BEAM, a web request can be performed synchronously whereas on JavaScript anything a fetch returns a promise.

It would be nice to reuse code between the two platforms.
Ideally business logic would be defined once and be generic over an implementation of fetch.
However to pass a fetch implementation on the JS platform would require business logic that works on promises.
That same business logic would not run on the BEAM as it has no concept of promises.

## The sans-io answer

The preferred solution in Gleam ecosystem is the sans-io style.
This style dictates that reusable code is written entirely without reference to the effect.
For example in ourcase we could group all pure logic for the input to fetch in one function and another pure function handles processing the output.

```gleam
fn fetch_input(key) {
  string.uppercase(key)
}

fn fetch_output(value) {
  string.length(output)
}
```
Both `fetch_input` and `fetch_output` can run on both platforms.
An implementation that composes these helpers and a concrete fetch implementation are writen for each platform.

On the BEAM we get:

```gleam
pub fn simple_func(fetch: fn(String) -> String) -> List(Int) {
  list.map(["a", "b"], fn(key) {
    key
    |> fetch_input
    |> fetch
    |> fetch_output
  })
}
```

For the JavaScript runtime we get.

```gleam
pub fn async_func(fetch: fn(String) -> Promise(String)) -> Promise(List(Int)) {
  list.map(["a", "b"], fn(key) {
    use value <- promise.map(fetch(fetch_input(key)))
    fetch_output(value)
  })
  |> promise.await_list
}
```

Using the sans-io pattern offers some improvement, the domain logic lives in pure functions that are testable.

But look at what remains in the platform code.
The iteration over the keys, the wiring of `fetch_input` into `fetch` into `fetch_output` and the collection of results are all duplicated.

The sans-io pattern offers no way to reuse code that composes multiple effects.
In this case iterating through the list results in multiple calls to fetch.
A real program might have multiple kinds of effects, say database or file system access, intricately composed.

The more logic in plumbing effects together then the less value provided by the sans io pattern.

## Composing with continuations.

In the previous post I showed how the original function could be rewritten using continuations.

```gleam
import midas/cont

pub fn task(fetch: fn(String) -> Cont(t, String)) -> Cont(t, List(Int)) {
  let keys = ["a", "b"]
  cont.each(keys, fn(key) {
    let key = string.uppercase(key)
    use value <- cont.then(fetch(key))
    cont.return(string.length(value))
  })
}
```

The plumbing lives in task, all in one place.
The iteration, calling `fetch`, the flow of one value into the next step are all defined by task itself.
A caller no longer composes the program from sans-io parts.
The caller is a runner that only supplies an implementation of fetch and a final callback.

```gleam
fn run_simple(task) -> List(Int) {
  let fetch = fn(_key) { return("yes") }

  task(fetch)(fn(x) { x })
}

fn run_async(task) {
  let fetch = fn(_key) {
    fn(then) {
      use Nil <- promise.await(promise.wait(100))
      then("slow")
    }
  }

  task(fetch)(promise.resolve)
}
```

Also observer that `run_simple` and `run_sync` are completly reusable for any task requiring an implementation of fetch.

# Have we solved it

Operations on a continuation look suspiciously like those on a promise.
The `task` function returns a continuation and the operations on a continuation mirror the operations on a promise.
`cont.return` is `promise.resolve`, `cont.then` is `promise.then`.
So, have we escaped function colouring, or just invented a new colour?

The answer is subtle.
Without an implementation of `fetch` the only way to work with values from task is to use `cont.then` and return another continuation.
This is function colouring and the use of continuations will permiate up the call stack.

The difference is when a caller chooses an implementation of fetch.
On the BEAM a synchronous implementation of fetch is provided.
When running on JS a promise based implementation is provided.

This choice is where we uncolour our function.
When our business logic was built around promises if was impossible to av

Function colouring is an useful analogy but the actual problem to solve was can we write our business logic to be reusable across the different 



## POST 4 Designing for continuations

This is the fourth time I've written about continuations in Gleam
Up to this point I've presented continuations as a great solution to effectful code, and they are.

However after choosing to use continuations there remain design details to consider.

Let's revisit our original solution using continuations.

```
fn one_function_to_rule_them_all(keys) {
  cont.traverse(keys, fn(x) {
    let key = string.uppercase(x)
    use value <- bind(get(key))
    return(string.length(value))
  })
}
```

Her the computation assumes a value is returned.
Handling a missing value is the responsibility of a caller.
This means any logic such as retries or fallbacks are handled in the caller. and if there are multiple implementations each caller needs to reimplement the logic.
We could assume that a missing value is a situation that happens in most stores and we have a way to deal with it.
Say a missing value could be counted at length zero.

```
fn one_function_to_rule_them_all(keys) {
  cont.traverse(keys, fn(x) {
    let key = string.uppercase(x)
    use value <- bind(get(key))
    case value {
      Some(value) -> return(string.length(value))
      None -> return(0)
    }
  })
}
```

We could go further and assume that a get function also always has the ability to fail.

```
fn one_function_to_rule_them_all(keys) {
  cont.traverse(keys, fn(x) {
    let key = string.uppercase(x)
    use value <- bind(get(key))
    case value {
      Ok(Some(value)) -> return(string.length(value))
      Ok(None) -> return(0)
      Error(_) -> return(-1)
    }
  })
}
```

The drawback to this approach is we no longer have a way to represent get functions that do not error.

My preference is to make as many assumptions as possible about the system. i.e. use the function returning `Result(Option(String),String)`
All the benefits of mocking discussed in part 3 are available for all signatures.
And testing code in the continuation is easier, because we have a standard mocking approach.