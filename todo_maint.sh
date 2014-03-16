#!/usr/bin/bash
PROG=`basename $0`

errout() {
    echo "$PROG: $1" >&2
    exit 1
}

cd /cygdrive/m/todo_priority_1 || errout "No directory."
ls ?[!_]* | while read a
do
    mv "$a" "X_$a"
done >/tmp/a.files
