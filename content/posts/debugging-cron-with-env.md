---
title: "Debugging cron with `env`"
date: 2020-11-03T11:42:10+01:00
summary: "Using the `env` command, we can simulate the environment cron runs in."
grimoire:
    - Linux
---

Sometimes cronjobs don't work as expected. One of the reasons for this is that
cron commands run with a different set of environment variables. While you can
redirect a script's output to a file in the crontab, I find it easier to run the
command myself and see the output directly.

## Quick & easy

The quick and easy way to simulate a cron command is to use `env -i`, which
creates a completely empty environment:

```bash
$ env -i <your command to run>
```

To illustrate the difference:

```bash
$ printenv | wc -l
54
$ env -i printenv | wc -l
0
```

## A more precise environment

`env -i` will be sufficient for most cases. However, cron's environment isn't
*completely* empty. If you want to run a command with exactly the same
parameters, you'll first have to export the parameters to a file in a cronjob.
For example:

```bash
* * * * * /usr/bin/env | sort > /tmp/cron_env_vars
```

You'll have to wait a minute for this, unfortunately. If you know a better way,
let me know!

Once the file is created, you can use `env` again to load the parameters from
it:

```bash
$ env -i $(cat /tmp/cron_env_vars | xargs) <your command to run>
```

Using `printenv` again to illustrate this:

```bash
$ env -i $(cat /tmp/cron_env_vars | xargs) printenv
HOME=/home/mark
LANG=en_US.UTF-8
LANGUAGE=en_GB:en
LOGNAME=mark
PATH=/usr/bin:/bin
PWD=/home/mark
SHELL=/bin/sh
```
