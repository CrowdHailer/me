import gleam/dict

// import gleam/javascript/promise.{type Promise}
import gleam/list
import gleam/result
import gleam/string
import midas/continuation.{type Continuation as K, return, then}

fn fetch(key: String) -> String {
  "value for " <> key
}

pub fn simple_func(fetch: fn(String) -> String) -> List(Int) {
  let keys = ["a", " b"]
  list.map(keys, fn(key) {
    let key = string.uppercase(key)
    let value = fetch(key)
    string.length(value)
  })
}

pub fn faliable_func(
  fetch: fn(String) -> Result(String, Nil),
) -> Result(List(Int), Nil) {
  let keys = ["a", " b"]
  list.try_map(keys, fn(key) {
    let key = string.uppercase(key)
    use value <- result.map(fetch(key))
    string.length(value)
  })
}

// pub fn async_func(fetch: fn(String) -> Promise(String)) -> Promise(List(Int)) {
//   let keys = ["a", " b"]
//   list.map(keys, fn(key) {
//     let key = string.uppercase(key)
//     use value <- promise.map(fetch(key))
//     string.length(value)
//   })
//   |> promise.await_list
// }

pub fn task(fetch: fn(String) -> K(t, String)) -> K(t, List(Int)) {
  let keys = ["a", "b"]
  continuation.each(keys, fn(key) {
    let key = string.uppercase(key)
    use value <- then(fetch(key))
    return(string.length(value))
  })
}

fn run_simple(task) {
  let get = fn(_key) { return("yes") }

  task(get)(fn(x) { x })
}

fn run_result(keys, task) {
  let get = fn(key) {
    fn(then) {
      case dict.get(keys, key) {
        Ok(value) -> then(value)
        Error(Nil) -> Error(Nil)
      }
    }
  }

  task(get)(Ok)
}

// fn run_async(task) {
//   let get = fn(_key) {
//     fn(then) {
//       use Nil <- promise.await(promise.wait(100))
//       then("slow")
//     }
//   }

//   task(get)(promise.resolve)
// }

pub type Effect(t) {
  Get(String, fn(String) -> Effect(t))
  Done(t)
}

pub type Eff(a, b, t) =
  fn(a) -> K(Effect(t), b)

fn get(key: String) -> K(Effect(t), String) {
  Get(key, _)
}

fn effect_test() {
  task(get)(Done)
}

fn fallible_get(x: String) -> Result(String, Nil) {
  todo
}

pub type Stop {
  Stop(Nil)
}

fn patched_test() {
  let get = fn(key) {
    fn(then) {
      case fallible_get(key) {
        Ok(value) -> then(value)
        Error(reason) -> Stop(reason)
      }
    }
  }
  task(get)(fn(_) { Stop(Nil) })
}
