
# sHORTCUT get help on shortcuts

DIRNAME=`dirname $0`
cd $DIRNAME

grep '[^]]sHORTCUT' * | sed -n '/[^]]sHORTCUT/ {
s?^\(^[^:]*\).*[^]]sHORTCUT  *\(.*\)?\1  \2?
p
}' >&2

