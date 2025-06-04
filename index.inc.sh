# shellcheck shell=bash

export -- OOXML_PATCHER_ROOT
OOXML_PATCHER_ROOT="$(realpath -mL -- "${BASH_SOURCE[0]}/..")"

docx-patcher.sh() {
    "$OOXML_PATCHER_ROOT/docx-patcher.sh" "$@"
}
