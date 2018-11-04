var state = 0
// Can say while state then have nil to stop
// Can state != special_stop_string
// Have a this exit function
while (true) {
  const message = await mailbox.receive({timeout: false})
  // Can send a exit message here as well

  console.log(message)
  state = state + 1
  if (from = message.from) { send(from, {type: 'pong'}) }
}
var state = 0

while (true) {
  const message = await mailbox.receive()
  console.log(state = state + 1)
}

// Not tail called optimized
async function loop(state, mailbox) {
  await mailbox.receive

  loop(state, mailbox)
}

function spawn(handle, init = () => { return {} }) {
  // GenBrowser.start
  var state = init()
  while (true) {
    const message = await mailbox.receive({timeout: false})
    state = handle(message, state)
  }
  // Just use an integer for local processes
  // use 0 for one with a mailbox
  // Need a system for intercepting local addresses
}

function Mailbox () {
  const messages = []
  var awaiting = undefined

  return {
    receive: () => {
      if (awaiting) { throw 'Mailbox alread has receiver'}
    }

  }
}

---
class: middle

## Comments on my example
Do we need to talk about send and self
possible can get away with it.
handler can have reference to ActorSystem can it work out self
no because more than one actor can be started with same handler

---
class: middle

If has acces to self dispatch function then can do continue and also look up self address

Somewhere else must exist the code to
put in mailbox directly
Mailbox without an address
GenBrowser gets one with an address.
put in mailbox from another browser
put in mailbox from the backend
The process of registering is separate from a mailbox
---
class: middle

```js

```
https://html.spec.whatwg.org/multipage/workers.html#navigator.hardwareconcurrency
Start that many threads
Round robin at startup of process
Have all the work to do in the centeralized process.
Pull based on own actors otherwise take unlocked.
Terminate worker that has not reported for a given amount of time.
Drop message, state and current work and send down messages.
Addresses are known locally so no need to monitor over the network.
GenBrowser addresses can be monitored because of connection down and timeout.
---
class: middle



All the way up to comms

Testing, Session types
Comms. exhaust
