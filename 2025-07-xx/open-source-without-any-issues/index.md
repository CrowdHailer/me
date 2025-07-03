---
layout: article
title: Open source without any issues.
abstract: Most of my repos are created without issues.
share_image: /2025-01-02/the-evolution-of-a-structural-code-editor/mobile.jpg
share_alt: Screenshot of a less than useful issue.
---

I create most of my new project repositories with issues disable.
Did you even know that was an option? I only recently found it.

The simplest explination I have for this choice is.

> This repository has no issues because I have no issues with that code.

The short version of why I do this is really simple.
At some point, possibly quite a while ago, this software worked for me, in my project and on my machine.

The slightly longer version of this story reflects my opinions on how to collaborate.
We a few tweeks for standard practice for open source. I think life can be more productive and less stressful for maintainer and contributor.

## There is no "should" when prioritising

In my last job I discovered this trick.
When deciding priorities eliminate any problem statement using "should".
For example:

- We should have better tests
- We should upgrade our dependencies
- We should generate the API code from the docs

These statements might be true, in fact they almost certainly are.

On the other hand.
Maybe all these imperfections are manageable in the current project.
Maybe the company is going bust next week and none will get done..
Maybe you "should" spend more time touching grass.

What is more interesting than what we SHOULD do is what we ARE going to do.

I have more than 200 on GitHub and contribute to many more.
They nearly all have something that SHOULD be improved but in reality.
Therefore for many of my open source libraries what I am going to do is nothing.

## Collaboration not obligation

I love collaboration, having removed issues doesn't change this.
It only changes the way I collaborate.

The code remains open source and therefore is nothing that you cannot fix.
My involvement doesn change what's possible. 
It might change how long it takes but we'll get back to this.

If the project infront of you is lacking in some way, and you cannot open an issue, two courses of action remain available:

1. Use the library in front of you and modify it as needed.
2. Find another library (or language/ecosystem) and use that.

If your biggest concer is to implement serverside code generation for OAS then get that done.
Always solve your problem first. 
*I talk about problem but the advice is the same if it's a side project or exploration.*

Once you have built a thing you can take a look at what you've got and decide what to do next.
It might not make sense to contribute to the library, you may have discovered why your usecase is special.

If you like what you have built and think it's worth contributing then open a pull request.
Now the collaboration will be based on something much more concrete.
And the conversation much more informed.

## All code doesn't need a community

The most common argument against this approach is what if people duplicate work.
This sounds a valid concern, but in most cases it is not.
For all my repositories with out issues the most common number of people working on them at any time is zero.

Optimistic concurrency control is the solution here. 
i.e. just start your contribution and open the PR the most likely outcome is that in the meantime no one has tackled the same issue.

What if you do the work and the PR isn't merged.
Well if you've followed my previous suggestion and been solving your own problems then never mind, your problem is solved.

But seriously I want to make contributions to help a community or project grow.
This is great and now we find the place where discussions belong.

I am very invested in the Gleam community growing and succeeding.
I like helping people contribute to the language and libraries.

There are hundreds of Gleam repositories and only one Gleam community.
There is no Gleam CSV community but there is a Gleam community.

Discussions about parsing CSV in Gleam might range over more than one libary and so fragmenting what the community
is discussing over small libraries is not a good thing.

Some projects might get large enough to warrent their own community. For example Lustre might be large enough to have it's own community.
Or maybe Gleam is a very small community and we should just have one community for all of the BEAM languages.
I don't know exactly the right level of granularity of community but I am sure there is no gleam_csv community.

## Default to action

Deafult to action is a YCombinator phrase. It means that you should default to doing something rather than discussing it.
Because sometimes what to do is obvious and if it's not then having tried something will make the discussion more informed when it needs to happen.

Option 3 from earlier was to open an issue and wait.
It's the only course of action in which you default to waiting.

The issue is not the problem the waiting is the problem.
This is not a good default.

## Conclusion

I do try and follow this advice from both sides





