1. running gleam build before eunit gave an error.
1. Surprised list of libraries includes erleans but nothing web
1. Generated project has no Gleam supervisor,
1. I like that it includes github tests, if a little more vendor lockin that just an assumption of git for gitignore. Not arguing because I use them.
1. Floats have separate operators, this is great my favourite feature. The only change I would make would be to remove float from the core library
1. Does gleam have a Repl, is that a hard thing, questions I don't know the answer to, in Elixir i run `h Module` often to find out whats there
1. tuple( syntax unexpectedly verbose, is there not a set of brackets that can be used without the word?
1. Completeness of Case statement
1. maybe tuple syntax alright as more often would use a custom type.

Section on writing erlang code inline
Section on publishing a library to hex
Not need to be public to be external
Careful to not use the same name
Is it a concious choice to require everything like string and list functionality.
Would there be a consideration to add `io.display` to standard lib.
Are there optional values in function args
clashing names of modules and variables
Nedd section on parametarised custom types
Template should create an app version of 0.1.0
Pin operator

Suggestion issue, io module puts debug or similar

Access local module as an atom for naming

Code generation

Traits like printable or sendable
Can you have a term that won't serialize so it works as not sendable.
If not sendable receive fn an self need to be separate, receive is not sendable fn is.

Can have an upgrade function from self(Never) -> Self(Running protocol) for an init step

articles
Gleam in Docker
Gleam Lang it's more ready than you think
A typed API for processes (actor concurrency)

Single error should be optional type, no need for timeout error.

```rust
let pid = task.spawn_link(fn(receive){
  case receive() {
    Message(x) -> x + 5
  }
})

process.send(pid, "String")
// Won't compile
```

Tricks with native code

- can write inline in native.erl files
- unrepresentable types

* I'm sticking with
* #beammeupdates

```rust
type API {
  // returns a function that takes one more type, the a before taking what was there before
  Match(String, API)
  Capture(String, fn(String) -> Result(a))
  Get(list_of_content_types, )
  Alternative(:<|>)
  Handler()
}

api = Choice(
  // Get returns if any string remaining
  Match("users", Get(fn() { [users] }))
  Match("users", Capture("user_id"))
)

Form(f) {
  Field(String, fn(String) -> Result(v, Nil), Form(tuple(v, f)))
  Required/Optional
  // Form of nil
  End
}

parse(f: Form(x)) -> Result(x, FormError)
parse(f: Form(a, Form(b, nil))) -> Result(x, FormError)

Capture(capture, handler)
```
