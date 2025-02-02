---
layout: article
title: Why are there not more operating systems?
abstract: There are more than often thought, and with EYG I'm responsible for building one more.
share_image: /2024-11-12/why-are-there-not-more-operating-systems/os.webp
share_alt: Generated image of a sea of operating systems.
---

**tl:dr** There are more than often thought, and with [EYG](https://eyg.run/) I'm responsible for building one more.

## How many truly independent operating systems exist?

For desktop computing there is Windows and MacOS. An unexpected surge from Linux would offer only three independent choices to cover all of desktop computing. In fact these three cover a lot more than just home desktops, as systems like hospital equipment, signs at the train station or industrial PC's are all very likely running Windows.

Extending our view to the mobile world adds Android. Maybe soon [Harmony OS](https://jamestown.org/program/harmonyos-next-beijings-bid-for-operating-system-independence/) can be added as a fully independent option.

There are nearly 10 Billion devices (~7 Billion smartphones and ~3 Billion desktops/laptops) in the world and running them all is this small handful of operating systems.

During [LIVE 2024](https://2024.splashcon.org/home/live-2024) last month I found myself part of an interesting discussion. Why are there not more operating systems?

Why are new operating systems not created? Is it particularly hard or simply unnecessary to create new ones? Very quickly, the need to agree a definition for "operating system" became apparent. 

## What is an operating system?

We all use operating systems, probably everyday and often before we get out of bed.
They are such a crucial part of our lives we must have some idea about what one is.

An operating system can be described as the stuff not in our application.
However this description isn't very satisfying because it actually describes what an operating system isn't.

The operating system consists of the file system, the drivers for screens, mice, keyboards etc as well as threads, memory management and user management.
This answer might be accurate but it's not very illuminating. We are really just describing a list of features.

A better question might be, what is the purpose of an operating system? Quoting from chatGPT:

> An operating system is software that manages computer hardware and provides services for computer programs, enabling them to run and interact with the hardware and user.

The purpose of an operating system is to run programs. The programs run on a computer and the operating system enables this. Finally we assume that some purpose can be found in those programs.

So in conclusion the operating system enables program/code/application/logic to run.

## Other systems for running code

Operating systems exist to run programs. They have ways to install, start, stop and interact with programs. The operating system is also responsible for providing programs with access to what they need from the outside world.

However, there are other systems that run and manage programs (or applications or code).

### Kubernetes

> Kubernetes, also known as K8s, is an open source system for automating deployment, scaling, and management of containerized applications.

Is Kubernetes an operating system? It exists to run applications. with functionality consisting of installing running and managing those applications on a set of hardware. 
One difference is that the hardware for Kubernetes is many machines and not a single one. That doesn't change that Kubernetes is an operating system especially considering that single machine operating systems have to manage multiple cores.

### Browsers

Browsers allow you to view websites. But today's websites nearly all come with some JavaScript, and without JavaScript many don't work.

Programs in the browser access the hardware via the Document Object Model (DOM). The DOM API is quite different to syscalls and security considerations restrict the power of this interface. 

Browsers are a way of installing, running and managing JavaScript programs and are therefore operating systems.

### Erlang

The Erlang VM can run bare metal, i.e. without an operating system, making it totally responsible for programs' access to the hardware.
It also has the ability to install new modules and update existing ones without restarting the VM.

Erlang is another operating system, where the module is the unit of program being managed.

### AWS Lambda and friends

The latest incarnation of the operating system are services like AWS lambda. These services allow you to install, run, and manage a single function.
Access to the outside world is managed in a UI or configuration language.

## Operating systems are a bag of utilities

Think of operating systems as the support structure for programs and there are lots of operating systems in existence. There are even more than covered so far such as emacs and it's plugins, embedded OS's and IPaas (like [IFTTT](https://ifttt.com/)).

Many new operating systems, and several new paradigms, were created over the previous decades. We fail to recognise them as operating systems because each incarnation gets a new name. Recently marketing departments would like you to call the systems for operating your programs a "platform".

New paradigms arrive because no single set of assumptions for running programs that holds for all situations.

In reality the classical operating systems, Window/MacOS, are a bag of utilities with some assumptions about computing from when they were created.

> Operating systems are a bag of utilities from the ~~90s~~ ~~70s~~ 60s.

This truth applies to the other things we talked about.

> Browsers are a bag of utilities from when objects were all the rage.

> Kubernetes is a bag of utilities from when YAML was the one true language.

## The value of an operating system

Operating systems are definitely useful for the things they provide to programs.
Each program does not need to reinvent functionality available from the platform.

Operating systems also provide value configuring and composing individual programs. The unix pipe stands as the preeminent example of composing programs.

When built as fixed bags of utilities platforms can get stuck in time, but this is solved by having multiple platforms suited to specific usecases.

## A future operating system

I was somewhat surprised to discover that I am building an operating system.

[EYG](https://eyg.run/) is a language that supports the type safe installation of new code into a running system. *Any language that supports `eval` can load new code however not many do it in a type safe manner.*

Access to the host environments (hardware or otherwise) can be managed at the level of an individual function using [algebraic effects and handlers](https://eyg.run/documentation/#perform-effect)

Further management and manipulation of functions is possible using efficient [closure serialization](https://eyg.run/documentation/#closure-serialization).

So in fact there are many systems to run programs. EYG is another solution in this space. One that brings type safety to the installation composition and configuration of programs.
