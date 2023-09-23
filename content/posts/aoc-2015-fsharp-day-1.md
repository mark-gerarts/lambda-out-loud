---
title: "Advent of Code 2015 in F# - Day 1"
date: 2023-09-17
lastmod: 2023-09-17
tags:
    - Fsharp
    - Advent of Code
summary: >
    Not Quite Lisp
---

[Day 1: Not Quite Lisp](https://adventofcode.com/2015/day/1).

We get a long list of parentheses as input. A `(` means "go up one floor", a `)`
means "go down one floor".

## Part One

The goal is to find the final floor after following all instructions. To achieve
this, we parse the parentheses as either `+1` or `-1`, and then simply sum them
up.

```fsharp
let parse c =
    match c with
    | '(' -> 1
    | ')' -> -1
    | _ -> failwithf "Unexpected character %c" c

let input = System.IO.File.ReadAllText(filename).Trim() |> Seq.map parse

input |> Seq.sum |> printfn "Part 1: %i"
```

## Part Two

We need to find the index of the first instruction that causes Santa to enter
the basement floor. Let's start with the full solution, and then break it down:

```fsharp
input
|> Seq.scan (+) 0
|> Seq.findIndex ((=) -1)
|> printfn "Part 2: %i"
```

The trick here is `Seq.scan`:

```fsharp
|> Seq.scan (+) 0
```

`Seq.scan` works like `Seq.fold`, but instead of returning the final result as a
single value, each step of the fold is saved and a list of these steps is
returned instead. An example:

```fsharp
Seq.scan (+) 0 [1; 0; 2] // Returns [1; 1; 3]
```

Once we have this, `Seq.findIndex` gives us our solution.

[Full solution](https://github.com/mark-gerarts/aoc/blob/main/2015/aoc-2015-fs/Day01.fs).
