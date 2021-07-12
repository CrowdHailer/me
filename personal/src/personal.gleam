import gleam/string
external fn log(any) -> Nil = "" "console.log"
// external pub type 

pub type Utterance {
    Utterance(
        transcript: String,
        alternatives: List(String),
        is_final: Bool
    )
}

// Listener/Agent
pub type State {
    Idle
    Awake
    Expectant
    Triggered
}

pub fn handle(utterance, state)  {
    // let utterance = Utterance("Yo", ["bo", "fo"], False)
    // log(utterance)
    case state {
        Idle | Awake -> {
            case recognise_wakeup(utterance) {
                Ok(utterance) -> {
                    log("Hello")
                    state
                }
                Error(_) -> state
            }
        }
        Expectant -> {
            case recognise_instruction(utterance) {
                Ok(_) -> state
                _ -> state
            }
        }
        Triggered -> state
    }
}

fn recognise_wakeup(utterance) {
    let Utterance(transcript, alternatives, ..) = utterance
    let transcript = string.lowercase(transcript)
    case string.starts_with(transcript, "hey colin") {
        True -> Ok(Nil) 
        False -> Error(Nil)
    }
}

fn recognise_instruction(utterance) {
    todo
}