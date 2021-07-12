import { handle, is_active } from "./generated_scripts/personal.js"
import { arrayToList } from "./generated_scripts/gleam/ffi.js";

var $command = document.getElementById("command")

var recognition = new webkitSpeechRecognition();
// Only executes if able to start a recognition
// $command.style.display = "block"
recognition.continuous = false;
recognition.lang = 'en-US';
recognition.interimResults = true;
recognition.maxAlternatives = 3;

recognition.onend = (_) => {
    recognition.start()
}


var triggered = false
recognition.onerror = (event) => console.log(event, "onerror")
let state = { type: "Idle" }
const listen = (x) => {
    // because continuous is false
    let utterance = x.results[0]
    let [first, ...rest] = utterance
    let transcript = first.transcript
    let alternatives = arrayToList(rest.map(({ transcript }) => transcript))
    let next = handle({ type: "Utterance", transcript, alternatives, is_final: utterance.isFinal }, state)
    let instruction = next[0]
    state = next[1]
    $command.style.display = is_active(state) ? "block" : "none";
    if (instruction.type === "Some") {
        var action = instruction[0].type
        if (action === "ShowGallery") {
            window.location.pathname = "/gallery"
        } else if (action === "GoHome") {
            window.location.pathname = "/"
        } else if (action === "ScrollDown") {
            window.scrollBy(0, window.innerHeight);
        } else if (action === "ScrollUp") {
            window.scrollBy(0, -window.innerHeight);
        }
    }
}
recognition.onresult = listen
recognition.start()
console.log("started");