
# purpose: modify task warrior tasks in bulk

# POSIX (maybe Bourne?)
lockdir=/tmp/taskwarrior.lock
if mkdir "$lockdir"
then
    echo >&2 "successfully acquired lock"

    # Remove lockdir when the script finishes, or when it receives a signal
    trap 'rm -rf "$lockdir"' 0    # remove directory when script finishes

    # Optionally create temporary files in this directory, because
    # they will be removed automatically:
    tmpfile=$lockdir/filelist

    ~/bin/td.pl
else
    echo >&2 "cannot acquire lock, giving up on $lockdir"
    exit 0
fi

