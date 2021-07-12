import { handle } from "./generated_scripts/personal.js"

var $command = document.getElementById("command")

// var grammar = '#JSGF V1.0; grammar colors; public <color> = aqua | azure | beige | bisque | black | blue | brown | chocolate | coral | crimson | cyan | fuchsia | ghostwhite | gold | goldenrod | gray | green | indigo | ivory | khaki | lavender | lime | linen | magenta | maroon | moccasin | navy | olive | orange | orchid | peru | pink | plum | purple | red | salmon | sienna | silver | snow | tan | teal | thistle | tomato | turquoise | violet | white | yellow ;'
var recognition = new webkitSpeechRecognition();
// var speechRecognitionList = new webkitSpeechGrammarList();
// speechRecognitionList.addFromString(grammar, 1);
// recognition.grammars = speechRecognitionList;
// We need to restart all the time end fires frequently. so do continous false and restart
recognition.continuous = false;
recognition.lang = 'en-US';
recognition.interimResults = true;
recognition.maxAlternatives = 3;

// recognition.onaudiostart = (x) => console.log(x, "onaudiostart")
// recognition.onsoundstart = (x) => console.log(x, "soundstart")
// recognition.onstart = (x) => console.log(x, "onstart")
recognition.onend = (x) => {
    recognition.start()
    console.log("continue waiting ...")
}


var triggered = false
// recognition.onnomatch = (x) => console.log(x, "onnomatch")
recognition.onerror = (x) => console.log(x, "onerror")
let state = { type: "Idle" }
const listen = (x) => {
    // because continuous is false
    let utterance = x.results[0]
    let [first, ...rest] = utterance
    let transcript = first.transcript
    let alternatives = arrayToList(rest.map(({ transcript }) => transcript))
    state = handle({ type: "Utterance", transcript, alternatives, is_final: utterance.isFinal }, state)
    console.log(state);
    return false
    // throw "BADDDD"
    for (const alternatives of x.results) {
        for (const { transcript } of alternatives) {
            if (transcript.toLowerCase().startsWith("hey colin") && triggered === false) {
                triggered = true
                $command.style.background = "#DDD";
                // console.log("Triggered");
                recognition.stop()
                console.log("process")
                recognition.onend = (x) => {
                    recognition.onresult = (x) => {
                        utterance = x.results[0][0].transcript
                        // console.log("other", utterance)
                        $command.innerText = utterance
                        if (utterance === "show gallery") {
                            window.location.pathname = "/gallery"
                        }
                        if (x.results[0].isFinal) {
                            // change order
                            console.log("finished");
                            recognition.stop()
                            recognition.onend = (x) => {
                                console.log("ended after finishing");
                                triggered = false
                                $command.style.background = "#FFF";

                                recognition.onresult = listen
                                recognition.onend = (x) => {
                                    recognition.start()
                                    console.log("continue waiting ...")
                                }
                                recognition.start()
                                console.log("restarting");
                            }
                        } else {
                            return
                        }
                    }
                    recognition.start()
                }
                // setTimeout(() => {
                //   command.start()
                //   // triggered = false
                //   // console.log("ready");
                // }, 0);
            }
        }
    }
}
recognition.onresult = listen


recognition.start()
console.log("started");
console.log("From main");

function arrayToList(items) {
    return items.reduceRight((tail, item) => [item, tail], [])
}