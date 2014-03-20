#    "g" - a helper script for performing git commands
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

#    sHORTCUT issue git commands
#    ^this line is necessary to work with s (shortcuts) command

#    $ g a myfile
#    git add myfile
#    $ g s
#    git status -s
#    M  myfile
#    ?? myfile.old
#    $ g
#    Usage: $ g n
#    where n is one of:
#           a   git add $*
#           c   git commit -a
#          cl   git clone git@github.com:tinypigdotcom/utility.git
#           d   git checkout develop $*
#           m   git checkout master $*
#          pm   git push origin master $*
#           s   git status -s $*
#

# -------------------------- Data: map option letter to its associated command
A="


     a  git add \$*
     b  git branch
     c  git commit -a
    cm  git commit -m \"\$*\"
     d  git checkout develop \$*
     m  git checkout master \$*
    pd  git push origin develop \$*
    pm  git push origin master \$*
     r  echo -n # git reset --hard HEAD
     s  git status -s \$*


"

# -------------------------- Setup -------------------------------------------
PROG=g
lookup=$1
shift

# -------------------------- Create or read other commands from config file --
if [ "x$HOME" != "x" ]; then
    UTILITY_DIR=$HOME/.utility
    CONFIG=$UTILITY_DIR/$PROG
    if [ ! -d "$UTILITY_DIR" ]; then
        mkdir $UTILITY_DIR
    fi
    if [ ! -f "$CONFIG" ]; then
        echo "# example config for $PROG script" >$CONFIG
        echo "$A" | sed -e 's/^/#/' >>$CONFIG
    fi
    if [ -r "$CONFIG" ]; then
        B=`grep -v '^ *#' $HOME/.utility/$PROG 2>/dev/null`
    fi
fi

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
done < <(echo "$B$A" | sort)

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

