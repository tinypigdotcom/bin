
# sHORTCUT interact with Git

# This is my shortcut script for git

usage() {
      sed -n '/^  *[a-zA-Z0-9][a-zA-Z0-9]*)/ {
s?^\(  *[a-zA-Z0-9][a-zA-Z0-9]*\)) *cmd="\(.*\)" *;;?\1  \2?
p
}' $0 >&2
}

lookup=$1
shift

case $lookup in
   a) cmd="git add $*" ;;
   b) cmd="git branch" ;;
   c) cmd="git commit -a" ;;
  cl) cmd="git clone git@github.com:tinypigdotcom/utility.git" ;;
  cm) cmd="git commit -m \"$*\"" ;;
   d) cmd="git checkout develop $*" ;;
   m) cmd="git checkout master $*" ;;
  pd) cmd="git push origin develop $*" ;;
  pm) cmd="git push origin master $*" ;;
   r) cmd="git checkout -b $*" ;;
   s) cmd="git status -s $*" ;;
  "") usage;;
   *) echo "Not valid." >&2
      usage;;
esac

echo $cmd >&2
eval $cmd

