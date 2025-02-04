---
layout: article
title: Programs don't kill people, computers do
abstract: This post outlines the evolution of the EYG editor. The major changes over time, design thoughts and some implementation notes.
share_image: /2025-01-24/eat-your-greens-a-philosophy-for-language-design/lift-effect.png
share_alt: The EYG editor and shell running on a phone.
---
<style>
  .morph.button {
    background: transparent;
  }
  .morph.button:hover {
    background-color: rgb(229, 231, 235);
}
</style>

The world outside our computers is unpredictable and interacting with it can make programs unreliable.
However, programs must interact with the wider world to do anything useful.
Our programs may need to update a screen, listen to a keyboard or launch the missiles.

Algebraic effects generalise communication between a program and the world, giving us control and insight.
Using algebraic effects is ergonomic and this single abstraction supersedes exception handling, state, iterators async-await and more.

To explain effects we start with the basics and look at the functions that make up our programs.

*[This post is part of a talk I gave, the section on algebraic effects starts at 14:17](https://youtu.be/bzUXK5VBbXc?si=XdZUA02ockI6ng5I&t=857)*

## What is a function?

Precisely defined in mathematics "a function is the relation between an input and an output, so that every input has exactly one output".
`uppercase` is a simple function where input and output are a single string.
`subtract` is a function with two integers as input and a single integer output.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/functions.png)

<div style="background:white;">
<script type="application/json+eyg">{"0":"l","l":"$","v":{"0":"@","p":"std","r":2},"t":{"0":"l","l":"string","v":{"0":"a","f":{"0":"g","l":"string"},"a":{"0":"v","l":"$"}},"t":{"0":"a","f":{"0":"a","f":{"0":"g","l":"uppercase"},"a":{"0":"v","l":"string"}},"a":{"0":"s","v":"hello"}}}}</script>
</div>

New functions can be defined by composing other functions and values.

For example `my_function` takes a single input from which it subtracts `5` before calculating the `absolute` value.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/composition.png)

<div style="background:white;">
<script type="application/json+eyg">{"0":"l","l":"$","v":{"0":"@","p":"std","r":2},"t":{"0":"l","l":"integer","v":{"0":"a","f":{"0":"g","l":"integer"},"a":{"0":"v","l":"$"}},"t":{"0":"l","l":"my_function","v":{"0":"f","l":"x","b":{"0":"l","l":"x","v":{"0":"a","f":{"0":"a","f":{"0":"a","f":{"0":"g","l":"subtract"},"a":{"0":"v","l":"integer"}},"a":{"0":"v","l":"x"}},"a":{"0":"i","v":5}},"t":{"0":"a","f":{"0":"a","f":{"0":"g","l":"absolute"},"a":{"0":"v","l":"integer"}},"a":{"0":"v","l":"x"}}}},"t":{"0":"a","f":{"0":"v","l":"my_function"},"a":{"0":"i","v":3}}}}}</script>
</div>

Functions are themselves values and can be the input, or output, of other functions.
Describing a language as having "first class functions" means that the language allows functions to put input or output of other functions.

In this example the `map` function takes two values.
The first input is a list of items and the second is the function `uppercase`.
Every item in the list is mapped to a new value using the uppercase function.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/function-as-value.png)
<div style="background:white;">
<script type="application/json+eyg">{"0":"l","l":"$","v":{"0":"@","p":"std","r":2},"t":{"0":"l","l":"string","v":{"0":"a","f":{"0":"g","l":"string"},"a":{"0":"v","l":"$"}},"t":{"0":"l","l":"list","v":{"0":"a","f":{"0":"g","l":"list"},"a":{"0":"v","l":"$"}},"t":{"0":"a","f":{"0":"a","f":{"0":"a","f":{"0":"g","l":"map"},"a":{"0":"v","l":"list"}},"a":{"0":"a","f":{"0":"a","f":{"0":"c"},"a":{"0":"s","v":"apple"}},"a":{"0":"a","f":{"0":"a","f":{"0":"c"},"a":{"0":"s","v":"orange"}},"a":{"0":"ta"}}}},"a":{"0":"a","f":{"0":"g","l":"uppercase"},"a":{"0":"v","l":"string"}}}}}}</script>
</div>


## Side effects and side causes

These next operations look sensible and indeed familiar when considering other languages.
However, these operations are not functions.
Why? Because a function is only a fixed relation from input to output.
**The same input must always produce the same output.**

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/not-functions.png)


A `print` function can be implemented that takes a string and returns an empty record, but without the outside world it will only be able to discard the input message.

The `random` function always takes the same input so must always produce the same output.
It's possible to have a `random` function that always returns 4.
That is probably not the behaviour expected for a function called random.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/random_number.png)
[_xkcd_](https://xkcd.com/221/)

*I use the term operation to distinguish from functions. Often the term pure function is used for a mathematical function and impure function for all the rest.*

Most languages have implicit effects.
Calling the operation `random` or `print` makes calls to the outside world adhoc without it being visible to the program.
The language will have decided ahead of time all the side effects that a program might use.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/side-effect.png)

Side effects expose the program to the whole world. Nothing in the program actually knows the limits of what the side effects do.
The whole world is big, complex and includes effects that might be permanent like launching the missiles.

## Controlling side effects

Because the external world is large and messy it is good practice to isolate our program, as much as possible, from the world.
Many languages control communication to the outside world to ensure predictable behavior.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/haskell.png)
[_xkcd_](https://xkcd.com/1312/)

Haskell uses the [IO monad](https://www.haskell.org/tutorial/io.html) to manage effects. 
Working with monads is a whole thing that we will not get into here.

Other languages make use of dependency injection to control effects.
For example an API client might be a required argument to a business function so that different implementations can be provided in staging or production.

Architectural patterns like [functional core, imperitive shell](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell) or hexagonal architecture exist to organise communication to the outside world.

In tests, effects are controlled using mocks, subs or doubles.

Algebraic effects are another way to manage side-effects and side-causes.
They require no syntactic overhead or force a particular architecture.

But first, a quick aside into continuations.

### Continuations

Explaining continuations is easiest with a concrete example.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/continuation.png)
<div style="background:white;">
<script type="application/json+eyg">{"0":"l","l":"$","v":{"0":"@","p":"std","r":2},"t":{"0":"l","l":"integer","v":{"0":"a","f":{"0":"g","l":"integer"},"a":{"0":"v","l":"$"}},"t":{"0":"l","l":"add_k","v":{"0":"f","l":"x","b":{"0":"f","l":"y","b":{"0":"f","l":"k","b":{"0":"l","l":"result","v":{"0":"a","f":{"0":"a","f":{"0":"a","f":{"0":"g","l":"add"},"a":{"0":"v","l":"integer"}},"a":{"0":"v","l":"x"}},"a":{"0":"v","l":"y"}},"t":{"0":"a","f":{"0":"v","l":"k"},"a":{"0":"v","l":"result"}}}}}},"t":{"0":"a","f":{"0":"a","f":{"0":"a","f":{"0":"v","l":"add_k"},"a":{"0":"i","v":1}},"a":{"0":"i","v":5}},"a":{"0":"f","l":"result","b":{"0":"a","f":{"0":"a","f":{"0":"a","f":{"0":"g","l":"subtract"},"a":{"0":"v","l":"integer"}},"a":{"0":"i","v":0}},"a":{"0":"v","l":"result"}}}}}}}</script>
</div>

In the first diagram `add` is function in the direct style.
The direct style means no continuations, `add` returns the sum of the two values and the surrounding program passes the result to `negate`.

Compare `add` with `add_k` which accepts an additional third argument `k`. This `k` is the continuation. 
`add_k` is responsible for calling the continuation with the sum of the other two values.
And the return value of `add_k` is the return of the whole program. 

A continuation is essentially the same as a callback.

You may have heard of [callback hell](http://callbackhell.com/) a situation where working with many callbacks becomes painful.
Algebraic effects don't suffer from "callback hell" because the continuation is passed automatically.

## Algebraic effects

Algebraic effects consistently model a program's interaction with the outside world.
Programs can handle all side-effects, side-causes using them, this includes:

- Input and output operations
- Non determinism i.e. random
- Time
- Exceptions
- Concurrency
- Mutability

To use an effect the program uses the perform keyword. 
This halts the program and creates an effect.
The effect consists of three fields.

1. A `label` indicating what kind of effect it is.
2. A `value` which is any data from the program to the external world.
3. A `resume` function which is the continuation representing the rest of the program.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/lift-effect.png)

Instead of a program calling a `random` "function" with implicit side effects it will perform the `Random` effect. 

The program is now pure as it consists of inputs and outputs without a reliance on the outside world. 
However, instead of returning the result we want our program returns a request to the outside world, the effect.
In English the effect is saying - please call resume when you have a value that satisfies the "Random" effect.

Once the surrounding environment has an answer for that effect it can call resume to continue the program.
The `resume` function is also pure.
To perform more effects another effect will be returned for the world to act on, in it's own time.

![](/2025-01-24/eat-your-greens-a-philosophy-for-language-design/resume.png)

Because resume is just a function it can be called more than once and potentially at a much later time.

Algebraic effects automatically pass the continuation when an effect occurs.
So you write regular code like below.

<div style="background:white;">
<script type="application/json+eyg">{"0":"l","l":"$","v":{"0":"@","p":"std","r":2},"t":{"0":"l","l":"integer","v":{"0":"a","f":{"0":"g","l":"integer"},"a":{"0":"v","l":"$"}},"t":{"0":"l","l":"result","v":{"0":"a","f":{"0":"p","l":"Random"},"a":{"0":"u"}},"t":{"0":"a","f":{"0":"a","f":{"0":"a","f":{"0":"g","l":"add"},"a":{"0":"v","l":"integer"}},"a":{"0":"v","l":"result"}},"a":{"0":"i","v":1}}}}}</script>
</div>

## Type inference

Algebraic effects can infer all the requirements a function has on the outside world.
To answer "does this function call the network?" or "does this function need a file system" referring to the function type signature will provide the answer.

Using algebraic effects is more precise than using `IOMonad`.
With `IOMonad` a function can only be pure or impure, there is no differentiation between random or accessing the network.

Effects compose cleanly.

<div style="background:white;">
<script type="application/json+eyg">{"0":"l","l":"f","v":{"0":"f","l":"_","b":{"0":"a","f":{"0":"p","l":"Now"},"a":{"0":"u"}}},"t":{"0":"l","l":"g","v":{"0":"f","l":"message","b":{"0":"a","f":{"0":"p","l":"Alert"},"a":{"0":"v","l":"message"}}},"t":{"0":"l","l":"h","v":{"0":"f","l":"_","b":{"0":"a","f":{"0":"v","l":"g"},"a":{"0":"a","f":{"0":"v","l":"f"},"a":{"0":"u"}}}},"t":{"0":"z","c":""}}}}</script>
</div>

The function `f` has only the `Now` effect in it's type signature and `g` only the `Alert` effect.
The function `h` has a type signature that includes both effects.

## Conclusion

Algebraic effects are a convenient abstraction for modelling the interaction between a program and the world.
Programs are only a set of instructions.
It is the job of a computer to run those instructions.

There are several benefits to algebraic effects.
- They allow the effects of any function to be precisely inferred.
- They are cleaner when compared to other approaches for controlling effects.

In a later post we will discuss handlers and how to intercept and modify effects in our programs.
For now the best description I have of effect handlers is the [EYG documentation](https://eyg.run/documentation/)

<script src="/2025-01-24/eat-your-greens-a-philosophy-for-language-design/embed.js"></script>