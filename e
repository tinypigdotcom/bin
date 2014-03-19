
# sHORTCUT edit file in your bin directory

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
        *) cmd="cd $HOME/bin; vim $lookup $*" ;;
esac

echo $cmd >&2
eval $cmd
