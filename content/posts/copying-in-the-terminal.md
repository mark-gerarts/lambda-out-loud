---
title: "Copying in the terminal"
date: 2021-01-03T13:05:34+01:00
summary: "Copy terminal output using `xclip`"
grimoire:
    - Linux
tags:
    - Linux
---

[`xclip`](https://github.com/astrand/xclip) is a useful tool to copy output from
the terminal directly to your clipboard. It's typical usage is as follows:

```bash
$ echo "Hello, world" | xclip -selection clipboard
```

I've put this in an alias to save some precious keystrokes:

```bash
$ alias cclip='xclip -selection clipboard'
$ echo "Hello, world" | cclip
```
