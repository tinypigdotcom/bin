
# purpose: edit file in your bin or bin2 directory

VERSION=0.0.1
BASENAME=`basename $0`

usage() {
    echo "Usage: $BASENAME file" >&2
}

if [ -n "$1" ]; then
    lookup=$1
    shift
fi

case $lookup in
       -?) usage;;
       -h) usage;;
   --help) usage;;
       "") cmd="f 1" ;;
        *) if [ -f $HOME/bin2/$lookup ]; then
               cmd="cd $HOME/bin2; vim $lookup $*"
           else
               cmd="cd $HOME/bin; vim $lookup $*"
           fi;;
esac

echo $cmd >&2
eval $cmd

