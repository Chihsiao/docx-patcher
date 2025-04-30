# shellcheck shell=bash

function bool() {
    local truth="${1?no truth}"

    [[ "$truth" =~ ^(1|on|true)$ ]] \
        || return 1

    return 0
}

function xml_escape_string() {
    local string="${1:?no string}"

    string="$(xmlstarlet escape "$string")"
    string="${string//\\/\\\\}"
    string="${string//\"/\\\"}"

    printf '%s\n' "$string"
}

function parse_var_descriptor() {
    local var_descriptor="${1:?no var_descriptor}"

    local var_name="${var_descriptor%%[:\?\-]*}"
    local modifiers="${var_descriptor:${#var_name}:2}"
    local operator="${modifiers:(-1)}"

    local check_empty_flag=1

    if [[ "${modifiers:0:1}" != ":" ]]; then
        modifiers="$operator"
        check_empty_flag=0
    fi

    local arg="${var_descriptor:${#var_name}+${#modifiers}}"

    [[ ! -v __name ]] || __name="$var_name"
    [[ ! -v __check_empty_flag ]] || __check_empty_flag="$check_empty_flag"
    [[ ! -v __operator ]] || __operator="$operator"
    [[ ! -v __arg ]] || __arg="$arg"
}

function extract_lines() {
    local var_descriptors lines

    var_descriptors=("${@:1:${#@}-1}")
    readarray -t lines < "${*:(-1)}"

    local i=0
    local var_descriptor line

    for var_descriptor in "${var_descriptors[@]}"; do
        line="${lines[$i]}"

        local \
          __name='' \
          __check_empty_flag='' \
          __operator='' \
          __arg=''
        parse_var_descriptor "$var_descriptor"

        local value="$line"
        case "$__operator" in
            '?') value="${value:?${__arg}}";;
            ':') value="${value:-${__arg}}";;
        esac

        declare -n -- var_ref="$__name"
        # shellcheck disable=SC2034
        var_ref="$value"
        i=$((i+1))
    done
}

function store_args() {
    if bool "${_unset-0}"; then
        __arguments+=("${@%%[:\?\-]*}")
        return 0
    fi

    local var_descriptor
    for var_descriptor in "$@"; do
        local \
            __name='' \
            __check_empty_flag='' \
            __operator='' \
            __arg=''
        parse_var_descriptor "$var_descriptor"

        local value; unset value
        if [[ -v "$__name" ]] && ([[ -n "${!__name}" ]] || ! bool "$__check_empty_flag"); then
            value="${!__name}"
        fi

        case "$__operator" in
            '?') value="${value?${__arg}}";;
            '-') value="${value-${__arg}}";;
        esac

        if [[ -v value ]]
            then __arguments+=("$__name=$value")
            else __arguments+=("$__name")
        fi
    done
}
