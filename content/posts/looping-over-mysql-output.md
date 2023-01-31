---
title: "Looping Over MySQL Output"
date: 2023-01-31
summary: "Execute a bash command for every row of a MySQL response."
grimoire:
    - MySQL
tags:
    - MySQL
    - SQL
---

Executing a bash command for every row of a query result is a useful trick to
know. As an example, I worked on an application where each order was sent to an
external bookkeeping system. This bookkeeping system would have the occasional
downtime, after which we had to manually correct the pending orders.

We used something like this:

```bash
mysql --user=<user> --password=<password> <database> \
  -e 'SELECT order_number FROM orders WHERE synced=0;' -B \
  | tail -n +2 \
  | xargs -I{} bin/console order:sync --order-number="{}"
```

## Breakdown

```bash
mysql --user=<user> --password=<password> <database> \
  -e 'SELECT order_number FROM orders WHERE synced=0;' -B
```

This executes the SQL query and returns the result tab-separated (`-B`), instead
of the normal output. This way, we don't have to do any additional parsing, as
every line consists of only the order number.

```bash
tail -n +2
```

Skip the header row using `tail`.

```bash
xargs -I{} bin/console order:sync --order-number="{}"
```

`xargs` allows us to execute a command for every line of input. We use `-I{}` to
specify that we want to use `{}` as a placeholder in the command. That is, every
occurrence of `{}` in the command gets replaced by the order number.
