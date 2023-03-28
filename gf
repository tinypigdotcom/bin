ALL=0
if [ "-a" == "$1" ]; then
    shift
    ALL=1
fi

PATTERN=$1
if [ $ALL -eq 0 ]; then
    PATTERN="/$1$"
fi

find . -follow | grep -i "$PATTERN" 2>/dev/null | grep -v '\.git'
