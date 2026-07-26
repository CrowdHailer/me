import gleam/option.{None, Some}
import personal/voice.{type State, Idle, Utterance}

pub fn initial_state() -> State {
  Idle
}

pub fn handle(
  transcript: String,
  alternative_one: String,
  alternative_two: String,
  is_final: Bool,
  state: State,
) {
  voice.handle(
    Utterance(transcript, [alternative_one, alternative_two], is_final),
    state,
  )
}

pub fn is_active(state: State) -> Bool {
  voice.is_active(state)
}

pub fn instruction_name(instruction) -> String {
  case instruction {
    None -> ""
    Some(voice.ShowGallery) -> "show-gallery"
    Some(voice.GoHome) -> "go-home"
    Some(voice.ScrollDown) -> "scroll-down"
    Some(voice.ScrollUp) -> "scroll-up"
  }
}
