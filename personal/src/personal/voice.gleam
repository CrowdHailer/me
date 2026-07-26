import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type Utterance {
  Utterance(transcript: String, alternatives: List(String), is_final: Bool)
}

pub type State {
  Idle
  Awake
  Expectant
  Triggered
}

pub type Instruction {
  ShowGallery
  GoHome
  ScrollDown
  ScrollUp
}

pub fn handle(
  utterance: Utterance,
  state: State,
) -> #(Option(Instruction), State) {
  case state {
    Idle | Awake ->
      case recognise_wakeup(utterance) {
        Ok(utterance) ->
          case recognise_instruction(utterance) {
            Ok(instruction) ->
              case utterance.is_final {
                True -> #(Some(instruction), Idle)
                False -> #(Some(instruction), Triggered)
              }
            Error(Nil) ->
              case utterance.is_final {
                True -> #(None, Expectant)
                False -> #(None, Awake)
              }
          }
        Error(Nil) -> #(None, state)
      }
    Expectant ->
      case recognise_instruction(utterance) {
        Ok(instruction) -> #(Some(instruction), Triggered)
        Error(Nil) -> #(None, state)
      }
    Triggered ->
      case utterance.is_final {
        True -> #(None, Idle)
        False -> #(None, state)
      }
  }
}

pub fn is_active(state: State) -> Bool {
  state == Awake || state == Expectant
}

fn recognise_wakeup(utterance: Utterance) -> Result(Utterance, Nil) {
  let words = utterance.transcript |> string.lowercase() |> string.split(" ")
  case words {
    ["hey", "colin", ..rest]
    | ["hi", "colin", ..rest]
    | ["yo", "colin", ..rest] ->
      Ok(Utterance(..utterance, transcript: string.join(rest, " ")))
    _ -> Error(Nil)
  }
}

fn recognise_instruction(utterance: Utterance) {
  [utterance.transcript, ..utterance.alternatives]
  |> list.filter(fn(value) { value != "" })
  |> match_instruction()
}

fn match_instruction(alternatives) {
  case alternatives {
    [] -> Error(Nil)
    [first, ..rest] ->
      case string.lowercase(first) {
        "show gallery" -> Ok(ShowGallery)
        "go back" | "go home" | "back" -> Ok(GoHome)
        "scroll down" | "page down" | "down" -> Ok(ScrollDown)
        "scroll up" | "page up" | "up" -> Ok(ScrollUp)
        _ -> match_instruction(rest)
      }
  }
}
