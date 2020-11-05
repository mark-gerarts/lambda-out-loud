---
title: "Functional creative coding"
date: 2020-04-11T11:07:30+01:00
summary: "Exploring creative coding options in functional languages."
---

Every once in a while I find myself returning to creative coding. Previously I
used [p5js] with [TypeScript] for this. Browsersync's hot reloading combined
with the excellent Processing environment makes for a really pleasant developer
experience.

This time, however, I wanted to use creative coding as a way to learn and
improve my knowledge of functional programming. There are a number of options
out there:

- **Haskell**'s most promising library for creative coding seems to be [gloss].
  It is stable and maintained, and has a few examples to get you started.
  Closely related is [Shine], which brings gloss to the browser.
- **PureScript** has a [nice library][purescript-p5] that provides p5js
  bindings. The author even published a [boilerplate
  project][purescript-p5-starter] that includes hot reloading.
- Another nice sketching library is **Clojure**'s [Quil]. It's intuitive, has
  good documentation, and is pleasant to work with. Coding is interactive, with
  changes being compiled quickly.
- For **Common Lisp** I can wholeheartedly recommend [trivial-gamekit]. It's
  technically a library to create 2D games, but it lends itself really well for
  creating sketches. You get an easy-to-use library combined with all the power
  Lisp has to offer.
- For a lightweight Haskell-like experience, there's **Elm**. [Elm-canvas]
  provides a nice wrapper around the HTML5 canvas, which is enough to get you
  started.

After briefly trying all these options I decided to spend some time to learn
Elm. It's *extremely* beginner friendly, allowing me to pick up functional
concepts at my own pace. [Elm-live] provides hot reloading, which makes for a
very satisfying development workflow combined with the always helpful compiler.
Elm does lack some powerful and intriguing concepts that are present in Haskell
and PureScript, so at some point I'll probably find myself wanting to dig deeper
into those. But until then Elm has plenty of learning opportunities to offer.

A thing I like to do when learning a language is to follow along with [Nature of
Code][nature-of-code]. Not only do you need to familiarize yourself with the
syntax, it forces you to explore various libraries as well. It's been a very
pleasant learning experience so far; you can follow the progress
[here][noc-elm].


[p5js]: https://p5js.org/
[TypeScript]: https://github.com/Gaweph/p5-typescript-starter
[gloss]: http://gloss.ouroborus.net/
[Shine]: https://github.com/fgaz/shine
[purescript-p5]: https://github.com/derektmueller/purescript-p5
[purescript-p5-starter]: https://github.com/derektmueller/purescript-p5-boilerplate
[quil]: http://www.quil.info/
[trivial-gamekit]: https://github.com/borodust/trivial-gamekit
[Elm-canvas]: https://package.elm-lang.org/packages/joakin/elm-canvas/latest/
[elm-live]: https://github.com/wking-io/elm-live
[nature-of-code]: https://natureofcode.com/
[noc-elm]: https://www.github.com/mark-gerarts/nature-of-code-elm
