
# sHORTCUT interact with task system

usage() {
      sed -n '/^  *[a-zA-Z0-9][a-zA-Z0-9]*)/ {
s?^\(  *[a-zA-Z0-9][a-zA-Z0-9]*\)) *cmd="\(.*\)" *;;?\1  \2?
p
}' $0 >&2
}

lookup=$1
shift

case $lookup in
   a) cmd="task add $* due:today;sleep 1;~/taskrpt" ;;
   b) cmd="task $* modify pri:M" ;;
   c) cmd="task $* modify pri:L" ;;
   j) cmd="task proj:job;echo task proj:job >$HOME/taskrpt" ;;
   h) cmd="task proj:heap; echo task proj:heap >$HOME/taskrpt" ;;
   i) cmd="echo n | task $* rc.confirmation:no delete;sleep 1;~/taskrpt" ;;
   l) cmd="task rc._forcecolor:on list | less -R" ;;
   n) cmd="task now;echo task now >$HOME/taskrpt" ;;
   p) cmd="echo n | task $* modify +postponed;sleep 1;~/taskrpt" ;;
   u) cmd="echo n | task $* modify -postponed;sleep 1;~/taskrpt" ;;
   x) cmd="task $* done;sleep 1;~/taskrpt" ;;
  "") usage;;
   *) echo "Not valid." >&2
      usage;;
esac

echo $cmd >&2
eval $cmd

