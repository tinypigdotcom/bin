# (c) 2014 David Bradford, Tinypig Computing
# This is free software to do with as you wish

# sHORTCUT change directory
# ^this line is necessary to work with s (shortcuts) command

# "c" - my shorcut script for easy change directory.
# Usage:
# $ . c b
# $ pwd
# /home/dbradford/bin
# $ . c s
# $ pwd
# /some/arbitrarily/log/path/you/dont/want/to/type
# (enter c by itself to get a list of options)
# $ c
# Usage: $ . c n
# where n is one of:
#    b  cd $HOME/bin
#    d  cd $HOME/Dropbox
#    s  cd /some/arbitrarily/log/path/you/dont/want/to/type

usage() {
      echo "Usage: $ . c n" >&2
      echo "where n is one of:" >&2
      sed -n '/^  *[a-zA-Z0-9][a-zA-Z0-9]*)/ {
s?^\(  *[a-zA-Z0-9][a-zA-Z0-9]*\)) *cmd="\(.*\)" *;;?\1  \2?
p
}' $PROG >&2
}

# Difficult to make PROG=$0 work because if this script is called correctly
# with '.' then $0 will be bash or whatever the shell is
PROG=/absolute/path/to/c

lookup=$1

cmd=
case $lookup in
   b) cmd="cd $HOME/bin" ;;
   d) cmd="cd $HOME/Dropbox" ;;
   s) cmd="cd /some/arbitrarily/log/path/you/dont/want/to/type" ;;
  "") usage;;
   *) echo "Not valid." >&2
      usage;;
esac

if [ -n "$cmd" ]; then
    echo $cmd >&2
    eval $cmd
fi
