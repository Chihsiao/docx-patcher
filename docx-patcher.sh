#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC1091

set -euo pipefail \
    ${DEBUG:+-x}

OOXML_PATCHER_ROOT="$(realpath -mL -- "${BASH_SOURCE[0]}/..")" \
    && readonly OOXML_PATCHER_ROOT

source "$OOXML_PATCHER_ROOT/lib/utils.inc.sh"
source "$OOXML_PATCHER_ROOT/lib/xml.inc.sh"
source "$OOXML_PATCHER_ROOT/lib/builder.inc.sh"

source "$OOXML_PATCHER_ROOT/lib/styles/index.inc.sh"
source "$OOXML_PATCHER_ROOT/lib/styles/alignment.inc.sh"
source "$OOXML_PATCHER_ROOT/lib/styles/border.inc.sh"

source "$OOXML_PATCHER_ROOT/lib/styles/run.inc.sh"
source "$OOXML_PATCHER_ROOT/lib/styles/para.inc.sh"
source "$OOXML_PATCHER_ROOT/lib/styles/tbl.inc.sh"

SCHEME="$(realpath -mL -- "${1}")"
SOURCE="$(realpath -mL -- "${2}")"
TARGET="$(realpath -mL -- "${3}")"

shift 3

if ! [ -v WORKSPACE ]; then
    WORKSPACE="$(mktemp -d)"
    trap 'rm -rf -- "$WORKSPACE"' EXIT
fi

WORKSPACE="$(realpath -mL -- "$WORKSPACE")"
unzip -q "$SOURCE" -d "$WORKSPACE"
pushd -- "$WORKSPACE" \
> /dev/null && {
    source "$SCHEME"
    rm -f -- "$TARGET"
    zip -q -r "$TARGET" .
    popd > /dev/null
}
