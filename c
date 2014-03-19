#    "c" - a helper script for easily changing directory
#    Copyright (C) 2014  David M. Bradford
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see https://www.gnu.org/licenses/gpl.txt
#
#    The author, David M. Bradford, can be contacted at:
#    davembradford@gmail.com
#

# -------------------------- Data: map option letter to its associated command
A="


     b   cd $HOME/bin
     s   cd /some/arbitrarily/log/path/you/dont/want/to/type
     u   cd ~/sandbox


"

# -------------------------- Setup -------------------------------------------
PROG=c
lookup=$1

# -------------------------- Display usage function --------------------------
usage() {
    echo "Usage: $ . c n" >&2
    echo "where n is one of:" >&2
    i=0
    while [  $i -lt ${#option[@]} ]; do
        echo "    ${option[$i]}   ${cmd[$i]}" >&2
        let i=i+1
    done
}

# -------------------------- Read data into array ----------------------------
let i=0
option[0]=
cmd[0]=
while read a b
do
    if [ "x$a" == "x" ]; then
        continue
    fi
    option[$i]="$a"
    cmd[$i]="$b"
    let i=i+1
done < <(echo "$A" )

# -------------------------- Search array for chosen option ------------------
mycmd=
i=0
while [  $i -lt ${#option[@]} ]; do
    if [ "$lookup" == ${option[$i]} ]; then
        mycmd=${cmd[$i]}
        break
    fi
    let i=i+1
done

if [ -n "$mycmd" ]; then
    echo $mycmd >&2
    eval $mycmd
else
    usage
fi

