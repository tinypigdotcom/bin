#!/bin/bash
# purpose: run task warrior reports

PROG=`basename $0`

errout() {
    echo "$PROG: $1" >&2
    exit 1
}

bin/tt >info/tt.txt
bin/j >info/j.txt
bin/r >info/r.txt
