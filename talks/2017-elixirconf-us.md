# GenClient, an actor in the browser

## Abstract

Distributed systems are hard, actors can make them easier.
Modern applications are distributed across clients and servers,
but Elixir can only help server side.
Or can it?

In this talk you'll learn why the browser is just one more actor.
We'll explore an how to add browsers to OTP and sending messages to users the Elixir way.

```elixir
GenServer.call({:via, World, "@dave"}, :hello)
```

## tl:dr

The curse of Elixir development is it often takes a day to implement the server and the rest of the week wrangling javascript to match the functionality.

This talk does not promise any magic bullet but discuss one way to model client server communications that closely resembles process to process communication within Elixir.

My main goal is to kickstart discussions around the distributed systems nature of client/server applications.
Something which is more and more relevant with the increasing sophistication of clients.
Understanding how to build distributed systems with Elixir is necessary for it to truely become the successor to Rails type MVC applications.


Extra things,

Make a human workers pool
