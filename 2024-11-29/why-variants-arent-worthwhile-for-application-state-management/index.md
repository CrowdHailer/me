---
layout: article
title: Why Variants Aren’t Worthwhile for Application State Management
abstract: Gleam cant model dependencies between current state and expected messages.
share_image: /2024-11-29/why-variants-arent-worthwile-for-application-state-management/clean.webp
share_alt: Generated image of this post, quite meaningless.
---

# Why Variants Aren’t Worthwhile for Application State Management

In functional programming, managing application state is one of the most fundamental yet challenging aspects of building software. Developers often strive to represent state transitions as cleanly as possible, with custom types and variants being a common go-to solution. At first glance, this seems like the perfect fit: variants can precisely encode the relationship between the application's state and the messages it can receive. However, as applications grow, this approach tends to show its limits.

This post explores why variants often fall short in practice and how alternative patterns might better serve your state management needs.

## The Temptation of Variants

Imagine a simple application with two states: Loading and Running. The typical way to model this in a functional language like Gleam or Elm might look like this:

```rust
type State {
  Loading
  Running
}

type Message {
  Ready
  UserDidA
  UserDidZ
}

fn update(msg, state) {
  case msg {
    Ready -> // Handle transition from Loading to Running
    UserDidA -> // Assert that state is Running
    UserDidZ -> // Assert that state is Running
  }
}
```

At first glance, this is elegant. Each state transition is encoded explicitly, and the compiler ensures that you handle all cases. However, there’s a hidden cost: boilerplate and fragility.
## The Problem With Variants
### 1. Message Handling Becomes Cumbersome

In a real-world app, you often need to handle a wide range of user actions (UserDidA, UserDidZ, etc.), but these actions are only valid in specific states. To enforce this, you might find yourself repeatedly asserting that the current state is correct:

```rust
case msg, state {
  Ready, Loading -> // Transition to Running
  UserDidA, Running -> // Handle action
  UserDidZ, Running -> // Handle action
  _, Loading -> #(state, effect.none())  // Ignore invalid messages
  _, _ -> // Panic or log unexpected combinations
}
```

Over time, this approach introduces unnecessary complexity. Every new state or message requires updates to the update function, increasing the risk of errors and introducing boilerplate code.
### 2. Variants Break Down With Unexpected Messages

No matter how carefully you design your system, unexpected messages can and will occur. For example:

- **Asynchronous Events:** A Ready message might arrive after the application has already transitioned to the Running state.
- **User Actions During Loading:** A user might click a button while the app is still in the Loading state, sending a UserDidA message prematurely.

Handling these scenarios gracefully often means either:

1. Ignoring the message, which can feel like a broken UI.
2. Adding extra boilerplate to ensure the app can recover from these "impossible" states.

In either case, the variant-based model becomes a hindrance rather than a help.
### 3. Over-Constraining the Model

By tying messages directly to specific states, you create rigid constraints that limit your ability to handle edge cases. For example:

- What happens if you receive a UserDidA message during Loading? Should you discard it, queue it, or handle it in some other way?
- What if a new feature introduces a third state that invalidates your current message-handling logic?

With variants, every new feature or edge case requires rethinking the entire state model, making it harder to scale your application.
## An Alternative: Flattened Models and Boolean Flags

Instead of using variants, consider a simpler approach: a single record that represents the entire state of your application. For example:

```rust
type Model {
  Model(
    loading: Bool,
    running_state: RunningState
  )
}

type RunningState {
  // Add fields for "running" state here
}
```

Here’s why this approach works better:

- **Flexibility:** The loading flag allows you to manage the Loading and Running states without introducing a separate variant.
- **Graceful Degradation:** Messages can be handled more robustly without requiring "impossible" assertions. For example:
  ```rust
  case model, msg {
      Ready, {loading: true} -> // Transition to Running
      UserDidA, {loading: false} -> // Handle action
      _, {loading: true} -> #(model, effect.none())  // Ignore gracefully
  }
  ```
- **Default States:** The RunningState can be initialized with default or "zero" values, ensuring the app never crashes due to uninitialized data.

## Another Alternative: Message Specialization

You can also split messages into categories based on their relevance to different states. For example:

```rust
type Message {
  LoadingMsg(LoadingMessage)
  RunningMsg(RunningMessage)
}

fn update(model, msg) {
  case model, msg {
    Loading, LoadingMsg(msg) -> update_while_loading(msg)
    Running, RunningMsg(msg) -> update_while_running(msg)
    _, _ -> #(model, effect.none())
  }
}
```

This approach centralizes the logic for each state, reducing boilerplate and making it easier to manage unexpected messages.

## Conclusion: Variants Aren’t Worth the Hassle

While variants can be useful in small, tightly scoped applications, they often introduce more problems than they solve as the app grows. By over-constraining your model, variants make it harder to handle edge cases, unexpected messages, and new features. Instead, consider more flexible alternatives like:

- Flattened models with flags.
- Specialized message types.
- Graceful handling of unexpected states.

These patterns allow your application to evolve without being bogged down by the rigidity of variants. So the next time you’re tempted to model your application state with variants, ask yourself: **Is it really worth it?** Chances are, it’s not.