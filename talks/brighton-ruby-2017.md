## Abstract

Elixir is often described as a functional language. While that is true it's not special to Ruby developers. This talk is about how Elixir achieves massive concurrency and even makes it easy. Starting from a beginner overview of the concurrency constructs we will then advance quickly to making a basic, yet performant, server.

# For Reviewers

## Details

The out line of the talk is.

1. Overview of working with processes
2. The properties of processes
3. Failure handling between processes
4. Finally a birdseye view of how you could set work with those to make a server.

## Pitch

I have seen several welcome to Elixir talks in a Ruby context. They have all started talking about the syntax, functional programming and immutability.

Because Ruby is able to handle a functional style so well, this is a talk about why Elixir is good for people who already like functional programming. The arguments for are also mostly academic.

By showing the process model, this talk demonstrates a capability the Ruby finds much harder to match. It also better explains why Elixir is distinct from other functional languages. 

I should give this talk because

- I built a [webserver](https://github.com/CrowdHailer/Ace) in Elixir, to teach myself about processes.
- I have already talked about it at ElixirLDN, similar talk different level.
