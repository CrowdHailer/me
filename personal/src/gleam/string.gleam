pub external fn starts_with(String, String) -> Bool =
  "" "String.prototype.startsWith.call"

pub external fn lowercase(String) -> String =
  "" "String.prototype.toLowerCase.call"

pub external fn length(String) -> String =
  "" "String.prototype.length.call"

// https://stackoverflow.com/a/2878746
external fn index_of(String, String) -> String =
  "" "String.prototype.indexOf.call"

// pub fn split_once(x: String, on substring: String) -> Result(#(String, String), Nil) {
//     let index = index_of(x, substring)
// }
external type Array(items)

external fn js_split(String, String) -> Array(String) =
  "" "String.prototype.split.call"

external fn js_join(Array(String), String) -> String =
  "" "Array.prototype.join.call"

// external fn arrary_reduce_right(Array(a), f(a, s) -> b, s) -> Nil = "" "Array.prototype.reduceRight.call"
// fn array_to_list(array: Array(a)) -> List(a) {
//   arrary_reduce_right(array, fn())
// }
external fn array_to_list(Array(a)) -> List(a) =
  "./ffi.js" "arrayToList"

external fn list_to_array(List(a)) -> Array(a) =
  "./ffi.js" "listToArray"

pub fn split(x, on substring) {
  js_split(x, substring)
  |> array_to_list()
}

// join needs list_to_array
pub fn join(x, separator) {
  x
  |> list_to_array()
  |> js_join(separator)
}
