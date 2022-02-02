---
title: "Exporting a MySQL query as CSV"
date: 2022-01-26
summary: |
    A commandline trick to export the result of a MySQL query as a CSV.
grimoire:
    - MySQL
tags:
    - MySQL
    - SQL
---

I found this snippet on [StackOverflow](https://stackoverflow.com/a/5395421) a
long time ago and have been thankfully using a slightly tweaked version of it
ever since. It exports the result of a database query to a CSV file, straight
from the commandline:

```bash
mysql -u <user> -p<password> <database_name> -e "SELECT * FROM users" -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\\\n/\n/g;s/\\\t/\t/g" > export.csv
```

The result is a CSV file that opens just fine in LibreOffice, which you can then
use to convert it to an Excel file as needed.

## Breaking it down

First, we connect to the database like we normally would:

```bash
mysql -u <user> -p<password> <database_name>
```

We then use `-e` to execute the given query directly. `-B` causes the query
output to be tab-separated instead of the normal table layout, as well as
escaping special characters like `\t` and `\n`:

```bash
-e "SELECT * FROM users" -B
```

Finally, we use `sed` to convert the output to a proper CSV file:

```
s/'/\'/         Escape all single quotes
s/\t/\",\"/     Replace all tabs with `","`
s/^/\"/         Add a `"` to the start of each line
s/$/\"/         Add a `"` to the end of each line
s/\\\n/\n/g     MySQL escapes \n in the output, so replace them again
s/\\\t/\t/g     Idem for \t
```

An alternative way to go about would be to use MySQL's [`INTO
OUTFILE`](https://stackoverflow.com/a/356605), but this requires specific
permissions.
