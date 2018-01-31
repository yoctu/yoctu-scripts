#!/bin/bash

retention="7"

OPTS="c:eEfhk:n:rstvx"
SELF=${0##*/}
USAGE="Usage: $SELF [$OPTS] <pattern>"
HELP="
  $USAGE

    keep <nb> file matching <pattern>, remove others (see man 7 glob).

        -c <nb>   keep <nb> files instead of default ($retention)
        -e        bash set -e
        -E        prompt on error
        -f        force (passed to /bin/rm)
        -h        this help
        -k <nb>   keep <nb> files instead of default ($retention)
        -n <nb>   keep <nb> files instead of default ($retention)
        -r        recurssiv (passed to /bin/rm)
        -s        don't act, just print what should be done
        -t        don't act, just print what should be done
        -v        verbose (passed to /bin/rm)
        -x        bash set -x

    Be aware that this program use the same pathname expansion as bash.
    Escape special characters you pass as arguments or use bash builtin
    'set -f' to disable and 'set +f' to re-enable pathname expansion.
    see also man 7 glob.

    ex: $0 -s ~/var/mail/backup/20\*
"

function _quit ()
{
    echo -e "$@" >&2
    exit 1
}

unset run force rmOpts

while getopts :$OPTS arg
do
    case "$arg" in
        c)    retention="$OPTARG"                                   ;;
        e)    setE="set -e"                                         ;;
        E)    trap "read -p 'an error occurred, press ENTER '" ERR  ;;
        f)    force=true rmOpts+=("-f")                             ;;
        h)    _quit "$HELP"                                         ;;
        k)    retention="$OPTARG"                                   ;;
        n)    retention="$OPTARG"                                   ;;
        r)    rmOpts+=("-r")                                        ;;
        s)    run="echo"                                            ;;
        t)    run="echo"                                            ;;
        v)    rmOpts+=("-v")                                        ;;
        x)    setX="set -x"                                         ;;
        :)    _quit "$SELF: option -$OPTARG needs an argument."     ;;
        *)    _quit "  $USAGE"                                      ;;
    esac
done

shift $(($OPTIND - 1))

$setE
$setX

# we could loop on many arguments, but we could not detect error if user input is not protected
# eg: $0 pattern* instead of $0 'pattern*'
[[ $# -eq 1 ]] || _quit "  $USAGE\n  (did you quote specials characters ?!)"

[[ "$retention" == *[![:digit:]]* ]] && _quit "$SELF: $retention: Invalid number."

# expand to null if pattern does not match anything.
shopt -s nullglob

# get a list of matching files/dir
list=($1)

# only keep $retention files/directory, delete the rest
for ((i=0; i < ${#list[*]} - $retention; i++))
do
    $run rm "${rmOpts[@]}" "${list[$i]}"
done


