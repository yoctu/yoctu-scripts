#!/bin/bash

SELF="${BASH_SOURCE[0]##*/}"
NAME="${SELF%.sh}"

OPTS="svxEh"
USAGE="Usage: $SELF [$OPTS]"

HELP="
$USAGE

    Options:
        -s      simulate
        -v      set -v
        -x      set -x
        -e      set -ve
        -h      Help

"

function _quit ()
{
    local retCode="$1" msg="${@:2}"

    echo -e "$msg"
    exit $retCode
}

while getopts "${OPTS}" arg; do
    case "${arg}" in
        s) _run="echo"                                                  ;;
        v) set -v                                                       ;;
        x) set -x                                                       ;;
        e) set -ve                                                      ;;
        h) _quit 0 "$HELP"                                              ;;
        ?) _quit 1 "Invalid Argument: $USAGE"                           ;;
        *) _quit 1 "$USAGE"                                             ;;
    esac
done
shift $((OPTIND - 1))

filename="$1"

filecontent="$(egrep -v '(define|undefine)' $filename)"

while read -a defined
do
    eval declare ${defined[1]}="${defined[2]}"
    filecontent="$(echo -e "$filecontent" | sed "s/\${${defined[1]}}/${!defined[1]}/g")"
done < <(grep define $filename | grep -v undefine)

echo -e "${filecontent}"

