#    "t" - a helper script for task warrior
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

#    sHORTCUT a helper script for task warrior
#    ^this line is necessary to work with s (shortcuts) command

#    $ t a foo
#    task add foo due:today;sleep 1;~/taskrpt
#    Created task 235.
#    $ t b 235
#    task 235 modify pri:M
#    Modifying task 235 'foo'.
#    Modified 1 task.
#    $ t i 235
#    echo n | task 235 rc.confirmation:no delete;sleep 1;~/taskrpt
#    Deleting task 235 'foo'.
#    Deleted 1 task.
#    Usage: $ t n
#    where n is one of:
#           a   task add $* due:today;sleep 1;~/taskrpt
#           b   task $* modify pri:M
#           i   echo n | task $* rc.confirmation:no delete;sleep 1;~/taskrpt
#           l   task rc._forcecolor:on list | less -R
#           n   task now;echo task now >/home/dave/taskrpt
#           x   task $* done;sleep 1;~/taskrpt

# -------------------------- Data: map option letter to its associated command
A="


     a  task add \$* due:today;sleep 1;~/taskrpt
     b  task \$* modify pri:M
     c  task \$* modify pri:L
     j  task proj:job;echo task proj:job >$HOME/taskrpt
     h  task proj:heap; echo task proj:heap >$HOME/taskrpt
     i  echo n | task \$* rc.confirmation:no delete;sleep 1;~/taskrpt
     l  task rc._forcecolor:on list | less -R
     n  task now;echo task now >$HOME/taskrpt
     p  echo n | task \$* modify +postponed;sleep 1;~/taskrpt
     u  echo n | task \$* modify -postponed;sleep 1;~/taskrpt
     x  task \$* done;sleep 1;~/taskrpt


"

# -------------------------- Setup -------------------------------------------
PROG=t
lookup=$1
shift

# -------------------------- Display usage function --------------------------
usage() {
    echo "Usage: $ $PROG n" >&2
    echo "where n is one of:" >&2
    i=0
    while [  $i -lt ${#option[@]} ]; do
        printf "    %4s   %4s\n" "${option[$i]}" "${cmd[$i]}" >&2
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
    eval "echo \"$mycmd\"" >&2
    eval $mycmd
else
    usage
fi

