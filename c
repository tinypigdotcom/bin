#    Copyright (C) 2014  David M. Bradford
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your u_option) any later version.
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
#    purpose: shorcut script for easy change directory

#    Usage:
#    $ . c b
#    $ pwd
#    /home/dbradford/bin
#    $ . c s
#    $ pwd
#    /some/arbitrarily/log/path/you/dont/want/to/type
#    (enter c by itself to get a list of u_options)
#    $ c
#    Usage: $ . c n
#    where n is one of:
#       b  cd $HOME/bin
#       s  cd /some/arbitrarily/log/path/you/dont/want/to/type
#       u  cd $HOME/utility

# -------------------------- Data: map u_option letter to its associated command
VERSION=0.1.2
u_HERE_DIRS="




"

# -------------------------- Setup -------------------------------------------
u_PROG=c
u_lookup=$1

# -------------------------- Create or read other directories from config file
if [ "x$HOME" != "x" ]; then
    u_UTILITY_DIR=$HOME/.utility
    u_CONFIG=$u_UTILITY_DIR/$u_PROG
    if [ ! -d "$u_UTILITY_DIR" ]; then
        mkdir $u_UTILITY_DIR
    fi
    if [ ! -f "$u_CONFIG" ]; then
        echo "# example config for $u_PROG script" >$u_CONFIG
        echo "$u_HERE_DIRS" | sed -e 's/^/#/' >>$u_CONFIG
    fi
    if [ -r "$u_CONFIG" ]; then
        u_CONFIG_DIRS=`grep -v '^ *#' $HOME/.utility/$u_PROG 2>/dev/null`
    fi
fi

# -------------------------- Display usage function --------------------------
usage() {
    echo "Usage: $ . $u_PROG n" >&2
    echo "where n is one of:" >&2
    u_i=0
    while [  $u_i -lt ${#u_option[@]} ]; do
        printf "    %-4s   ${u_cmd[$u_i]}\n" "${u_option[$u_i]}"
        let u_i=u_i+1
    done | sort -k 2 -t '#' >&2
}

# -------------------------- Read data into array ----------------------------
let u_i=0
u_option=( )
u_cmd=( )
while read u_a u_b
do
    if [ "x$u_a" == "x" ]; then
        continue
    fi
    u_option[$u_i]="$u_a"
    u_cmd[$u_i]="$u_b"
    let u_i=u_i+1
done < <(echo "$u_CONFIG_DIRS$u_HERE_DIRS" | sort )

# -------------------------- Search array for chosen u_option ------------------
u_my_cmd=
u_i=0
while [  $u_i -lt ${#u_option[@]} ]; do
    if [ "$u_lookup" == ${u_option[$u_i]} ]; then
        u_my_cmd=${u_cmd[$u_i]}
        break
    fi
    let u_i=u_i+1
done

if [ -n "$u_my_cmd" ]; then
    echo $u_my_cmd >&2
    eval $u_my_cmd
else
    usage
fi

unset u_options
unset u_a
unset u_b
unset u_CONFIG
unset u_HERE_DIRS
unset u_CONFIG_DIRS
unset u_option
unset u_cmd
unset u_i
unset u_my_cmd
unset u_lookup
unset u_UTILITY_DIR
unset u_PROG

