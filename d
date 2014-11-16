#!/bin/bash
# purpose: cd to directory of file in "p" project system
# NOTE: DO NOT USE "exit" ONLY "return" as this is sourced in the current
# shell

VERSION=0.0.2
PROG=d
USAGE_FIRST_LINE="Usage: $PROG SHORTCUT"

errout() {
    cat <<EOF_errout >&2
$PROG: $*
$USAGE_FIRST_LINE
Try '$PROG --help' for more information.
EOF_errout

    return 1
}

usage() {

    cat <<EOF_usage >&2
$USAGE_FIRST_LINE
cd to directory of file in "p" project system
Example: $PROG menu.h

  -h, --help                display this help text and exit
  -V, --version             display version information and exit
EOF_usage

}

version() {
   echo "$PROG $VERSION" >&2
}

OPTS=`getopt -o Vh -l 'version,help' -- "$@"`
if [ $? != 0 ]; then
    usage
    return 1
fi

eval set -- "$OPTS"

while [ $# -gt 0 ]
do
    case "$1" in
      -h | --help) usage
                   return
                   ;;
   -V | --version) version
                   return
                   ;;
               --) shift
                   break
                   ;;
                *) errout "Invalid option: $1"
                   ;;
    esac
    shift
done

cd $(zdir $1)

