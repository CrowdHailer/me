import gleam/option.{None, Some}
import personal/voice

fn utterance(transcript, final) {
  voice.Utterance(transcript, [], final)
}

pub fn ignores_unrecognised_idle_speech_test() {
  assert voice.handle(utterance("hello", True), voice.Idle)
    == #(None, voice.Idle)
}

pub fn recognises_each_wake_phrase_test() {
  assert voice.handle(utterance("hey colin", False), voice.Idle)
    == #(None, voice.Awake)
  assert voice.handle(utterance("hi colin", False), voice.Idle)
    == #(None, voice.Awake)
  assert voice.handle(utterance("yo colin", False), voice.Idle)
    == #(None, voice.Awake)
}

pub fn recognises_wake_phrase_case_insensitively_test() {
  assert voice.handle(utterance("HEY COLIN", False), voice.Idle)
    == #(None, voice.Awake)
}

pub fn handles_wake_phrase_and_command_together_test() {
  assert voice.handle(utterance("hey colin show gallery", True), voice.Idle)
    == #(Some(voice.ShowGallery), voice.Idle)
}

pub fn waits_for_command_after_final_wake_phrase_test() {
  let #(_, state) = voice.handle(utterance("hey colin", True), voice.Idle)
  assert state == voice.Expectant
  assert voice.handle(utterance("go home", True), state)
    == #(Some(voice.GoHome), voice.Triggered)
}

pub fn recognises_alternative_test() {
  let heard = voice.Utterance("noise", ["scroll down"], True)
  assert voice.handle(heard, voice.Expectant)
    == #(Some(voice.ScrollDown), voice.Triggered)
}

pub fn triggered_state_resets_on_final_result_test() {
  assert voice.handle(utterance("anything", True), voice.Triggered)
    == #(None, voice.Idle)
}

pub fn active_states_test() {
  assert voice.is_active(voice.Awake)
  assert voice.is_active(voice.Expectant)
  assert !voice.is_active(voice.Idle)
  assert !voice.is_active(voice.Triggered)
}
