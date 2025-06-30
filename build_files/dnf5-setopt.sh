#!/usr/bin/bash
set -euo pipefail

die() {
    local frame=0
    while caller $frame >&2; do
        ((++frame))
    done
    echo >&2 "${*:-Something went wrong}"
    echo >&1 ":"
    exit 0
}
trap 'die' ERR

_usage() {
    local -i status=${1:-0}
    printf >&2 'Usage: eval "%s <setopt|unsetopt> <repo_name|repo_id> <option>=<value>)"\n' "$(basename "$0")"
    return $status
}

while getopts "h" opt; do
    case $opt in
    h)
        _usage 0
        exit
        ;;
    *) ;;
    esac
done

CMD_STRING="dnf5 config-manager"
ACTION=$1
shift

case $ACTION in
setopt | unsetopt) CMD_STRING+=" $ACTION" ;;
*)
    die "ERROR: Only setopt|unsetopt are allowed as first param"
    ;;
esac

REPOS_RAW="$(
    cd "$(dirname "$0")"
    # shellcheck disable=SC2086
    ./dnf5-search.sh ${1//,/ }
)"
if [[ -z $REPOS_RAW ]]; then
    die "No repo found matching '$1'"
fi
shift

REPOS=()
mapfile -t REPOS <<<"$REPOS_RAW"

OPTIONS=()
while (($#)); do
    [[ -n ${_v:=${1##.}} ]] && OPTIONS+=("$_v")
    shift
done
unset -v _v

if [[ ${#OPTIONS[@]} -eq 0 ]]; then
    die "No options were providied"
fi

for repo in "${REPOS[@]}"; do
    for opt in "${OPTIONS[@]}"; do
        CMD_STRING+=" $repo.$opt"
    done
done

echo "$CMD_STRING"
