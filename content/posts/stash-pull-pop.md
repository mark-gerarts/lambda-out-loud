---
title: "Stash Pull Pop"
date: 2020-08-05T13:40:22+02:00
summary: "Fetch upstream changes easily, even if you have unstaged changes."
grimoire:
    - Git
tags:
    - Git
---

If you happen to work on the same branch with multiple people, it can be
cumbersome to pull from upstream if you have unstaged changes.

```bash
$ git pull --rebase
error: cannot pull with rebase: You have unstaged changes.
error: please commit or stash them.
```

For this I use a shell script that does the following:

- If there are no unstaged changes, simply pull from upstream
- Otherwise, first stash the changes and pop them afterwards

The script (e.g. `~/scripts/spp.sh`):

```bash
#!/bin/bash

# This script will stash local changes before pulling, if there
# are any.
if [[ `git status --porcelain --untracked-files=no` ]]; then
  git stash && git pull --rebase && git stash pop
else
  git pull --rebase
fi
```

Combined with an alias:

```bash
# ~/.bash_aliases
alias spp="~/scripts/spp.sh"
```
