import {
    handle,
    initial_state,
    instruction_name,
    is_active,
} from "./generated_scripts/personal/personal/client.mjs"

var $command = document.getElementById("command")

const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition

if (SpeechRecognition) {
var recognition = new SpeechRecognition();
// Only executes if able to start a recognition
// $command.style.display = "block"
recognition.continuous = false;
recognition.lang = 'en-US';
recognition.interimResults = true;
recognition.maxAlternatives = 3;

recognition.onend = (_) => {
    recognition.start()
}


recognition.onerror = (event) => console.log(event, "onerror")
let state = initial_state()
const listen = (x) => {
    // because continuous is false
    let utterance = x.results[0]
    let [first, ...rest] = utterance
    let transcript = first.transcript
    let alternatives = rest.map(({ transcript }) => transcript)
    let next = handle(transcript, alternatives[0] || "", alternatives[1] || "", utterance.isFinal, state)
    let instruction = instruction_name(next[0])
    state = next[1]
    $command.style.display = is_active(state) ? "block" : "none";
    if (instruction !== "") {
        if (instruction === "show-gallery") {
            window.location.pathname = "/gallery"
        } else if (instruction === "go-home") {
            window.location.pathname = "/"
        } else if (instruction === "scroll-down") {
            window.scrollBy(0, window.innerHeight);
        } else if (instruction === "scroll-up") {
            window.scrollBy(0, -window.innerHeight);
        }
    }
}
recognition.onresult = listen
recognition.start()
console.log("started");
}
