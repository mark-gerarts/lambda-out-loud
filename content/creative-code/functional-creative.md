---
title: "Functional creative coding"
date: 2020-04-07T11:07:30+01:00
scriptNames:
    - https://unpkg.com/elm-canvas@2.2/elm-canvas.js
    - /static/js/magnetic-grid.min.js
image:
    file: "/static/img/magnetic-grid.png"
    alt: "Magnetic grid sketch"
summary: "Exploring creative coding options in functional languages."
---

{{< elm-canvas >}}

Every once in a while I find myself returning to creative coding. Previously I
used [p5js] with [TypeScript] for this. Browsersync's hot reloading combined
with the excellent Processing environment makes for a really pleasant developer
experience.

This time, however, I wanted to use creative coding as a way to learn and
improve my knowledge of functional programming. There are a number of options
out there, but few come close to p5js.

## The functional landscape

**Haskell** is *the* functional programming language. It was my first choice
because it feels as if you can never stop learning new concepts with Haskell.
The most promising library for creative coding seems to be [gloss]. It is stable
and maintained, and has a few examples to get you started. Closely related is
[Shine], which brings gloss to the browser.

My biggest hurdle with Haskell is and has always been the tooling. Do I use
Cabal or Stack? How do I properly set up my IDE? Where does Nix fit in the
picture? Don't get me wrong - I absolutely love the language. I just want my
development workflow to be as easy as possible so I can focus on creativity and
learning functional paradigms. I will definitely give gloss a shot in the future
though.

Closely related to Haskell is **PureScript**. There's a [nice
library][purescript-p5] that provides p5js bindings. The author even published a
[boilerplate project][purescript-p5-starter] that includes hot reloading. It was
pretty easy to get something small up and running, but I quickly ran into
frustrations. I came across a [blog post][purescript-blog-post] that perfectly
summarizes the experience:

> [PureScript] is the hardest parts of Haskell combined with almost no
> documentation.

This lack of beginner-friendliness discouraged me from continuing to work with
PureScript.

Another nice sketching library is **Clojure**'s [Quil]. It's intuitive, has good
documentation, and is pleasant to work with. Coding is interactive, with changes
being compiled quickly. However, types make me feel warm and fuzzy inside, and
this is what I'm missing with Clojure.

If you're into Lispy languages, I can wholeheartedly recommend
[trivial-gamekit], a library to create 2D games in **Common Lisp**. It's main
goal is to be easy to use, and it really does succeed in this. It will
especially feel familiar if you're coming from Processing. On top of being easy
to learn, it comes with all the power of Lisp: macros, a fantastic REPL, live
editing, parentheses, and almost 40 years worth of history. As much as I love
Lisp though, I was on the lookout for a language with a strong type system.

## Elm

I came across **Elm** multiple times, but I have to admit I initially dismissed
it. I heard it was comparable to a simplified version of Haskell, and code
samples I found online all had these weird formatting rules!

Well, after trying it out and creating a small sketch using [elm-canvas] I was
pleasantly surprised. The Elm community actively does its best to create a
beginner friendly environment and it really shows. The compiler is on a whole
new level of usability: error messages are super helpful and most of the times
exactly tell you what to do to solve your errors. Once everything compiles, your
code will probably do exactly what you want (barring tweaking a few numbers),
which is very satisfying. The ecosystem is vast, with lots of quality libraries.
Some libraries are not compatible with the newest Elm version, but oftentimes
there are plenty alternatives to find. Documentation is easy to find. Not only
for libraries, but especially surprising was the documentation around tooling.

elm-live


Stuff to like about Elm: consistency

- Consistent formatting (not configurable!)
- Consistent documentation
- consistent architecture

Some things not so nice:

- *Too* simple at times, missing the power of Haskell
- Stuck in the Elm architecture

[p5js]: https://p5js.org/
[TypeScript]: https://github.com/Gaweph/p5-typescript-starter
[gloss]: http://gloss.ouroborus.net/
[Shine]: https://github.com/fgaz/shine
[purescript-p5]: https://github.com/derektmueller/purescript-p5
[purescript-p5-starter]: https://github.com/derektmueller/purescript-p5-boilerplate
[purescript-blog-post]:
https://discourse.elm-lang.org/t/elm-canvas-examples/3464/7
[quil]: http://www.quil.info/
[trivial-gamekit]: https://github.com/borodust/trivial-gamekit
[elm-canvas]: https://package.elm-lang.org/packages/joakin/elm-canvas/latest/
