import gleam/string

external fn log(any) -> Nil =
  "" "console.log"

// external pub type 
pub type Utterance {
  Utterance(transcript: String, alternatives: List(String), is_final: Bool)
}

// Listener/Agent
pub type State {
  Idle
  Awake
  Expectant
  Triggered
}

pub type Option(a) {
  Some(a)
  None
}

pub type Instruction {
  ShowGallery
  GoHome
  ScrollDown
  ScrollUp
}

// TODO needs timeout
pub fn handle(utterance, state) {
  case state {
    Idle | Awake ->
      case recognise_wakeup(utterance) {
        Ok(utterance) ->
          case recognise_instruction(utterance) {
            Ok(instruction) -> case utterance.is_final {
                True -> #(Some(instruction), Idle)
                False -> #(Some(instruction), Triggered)
              }
            _ ->
              case utterance.is_final {
                True -> #(None, Expectant)
                False -> #(None, Awake)
              }
          }
        Error(_) -> #(None, state)
      }
    Expectant ->
      case recognise_instruction(utterance) {
        Ok(instruction) -> #(Some(instruction), Triggered)
        _ -> #(None, state)
      }
    Triggered ->
      case utterance.is_final {
        True -> #(None, Idle)
        False -> #(None, state)
      }
  }
}

pub fn is_active(state) {
  case state {
    Awake | Expectant -> True
    _ -> False
  }
}

fn recognise_wakeup(utterance) -> Result(Utterance, Nil) {
  let Utterance(transcript, alternatives, ..) = utterance
  let transcript = string.lowercase(transcript)
  case string.split(transcript, " ") {
    ["hey", "colin", ..rest] | ["hi", "colin", ..rest] | ["yo", "colin", ..rest] -> {
      let transcript = string.join(rest, " ")
      // TODO alternatives, needs a list filter function
      let utterance = Utterance(transcript, [], utterance.is_final)
      Ok(utterance)
    }
    _ -> Error(Nil)
  }
}

fn recognise_instruction(utterance) {
  let Utterance(transcript, alternatives ..) = utterance
  match_instruction([transcript, ..alternatives])
}

fn match_instruction(alternatives) {
  case alternatives {
    [] -> Error(Nil)
    [first, ..rest] -> {
      case first {
        // Need string.contain etc in std library
        "show gallery" -> Ok(ShowGallery)
        "go back" | "go home" | "back" -> Ok(GoHome)
        "scroll down" | "page down" | "down" -> Ok(ScrollDown)
        "scroll up" | "page up" | "up" -> Ok(ScrollUp)
        _ -> {
          log(first)
          match_instruction(rest)
        }
      }
    }
  }
}