find . -follow | grep -i "$@" 2>/dev/null | grep -v '\.git'
