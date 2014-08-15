
# purpose: interact with mysql

usage() {
      sed -n '/^  *[a-zA-Z0-9][a-zA-Z0-9]*)/ {
s?^\(  *[a-zA-Z0-9][a-zA-Z0-9]*\)) *cmd="\(.*\)" *;;?\1  \2?
p
}' $0 >&2
}

lookup=$1
shift

case $lookup in
   q) cmd="mysql --user=root --password=NOT_PASSWORD menagerie" ;;
  "") usage;;
   *) echo "Not valid." >&2
      usage;;
esac

echo $cmd >&2
eval $cmd

