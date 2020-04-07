---
title: "Functional creative coding"
date: 2020-03-30T11:07:30+01:00
scriptNames:
    - https://unpkg.com/elm-canvas@2.2/elm-canvas.js
    - /static/js/magnetic-grid.min.js
image:
    file: "/static/img/magnetic-grid.png"
    alt: "Magnetic grid sketch"
summary: "Exploring creative coding options in functional languages."
---

{{< elm-canvas >}}

Every one in a while I find myself returning to creative coding. Previously I
used [p5js] with [TypeScript] for this. Browsersync's hot reloading combined
with the excellent Processing environment make for a really pleasant developer
experience.

This time, however, I wanted to use creative coding as a way to improve my
knowledge of functional programming. There are a number of options out there,
but few come close to p5js.

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
[boilerplate project][purescript-p5-starter] that includes hot reloading.

> [PureScript] is the hardest parts of Haskell combined with almost no documentation.

Blog link: https://discourse.elm-lang.org/t/elm-canvas-examples/3464/6

- Purescript
  - Arcane/lack of documentation (hard parts of Haskell w/o docs)
  - Bindings for P5
- Clojure
  - Quil, CL, trivial gamekit
  - No types
- Elm


Stuff to like about Elm

- Simple, familiar syntax
- Great compiler output
- Once everything compiles, it usually just works
- Active ecosystem

Some things not so nice:

- *Too* simple at times, missing the power of Haskell
- Stuck in the Elm architecture

[p5js]: https://p5js.org/
[TypeScript]: https://github.com/Gaweph/p5-typescript-starter
[gloss]: http://gloss.ouroborus.net/
[Shine]: https://github.com/fgaz/shine
[purescript-p5]: https://github.com/derektmueller/purescript-p5
[purescript-p5-starter]: https://github.com/derektmueller/purescript-p5-boilerplate
