# shellcheck shell=bash

declare -A -- XML_NAMESPACES=(
    ['t']='http://schemas.openxmlformats.org/package/2006/content-types'
    ['r']='http://schemas.openxmlformats.org/package/2006/relationships'
    ['w']='http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    ['a']='http://schemas.openxmlformats.org/drawingml/2006/main'
)

xmlstarlet_ns_flags=()
xsl_root_ns_attrs=()

:xml.flush_ns() {
    xmlstarlet_ns_flags=()
    xsl_root_ns_attrs=()

    local key
    for key in "${!XML_NAMESPACES[@]}"; do
        local value="${XML_NAMESPACES[$key]}"
        xmlstarlet_ns_flags+=(-N "$key=$value")
        xsl_root_ns_attrs+=("xmlns:$key=\"$(xml_escape_string "$value")\"")
    done
}

:xml.file() {
    declare -g -- xml_file="${1:-}"
}

:xml.proc() {
    local template="${1:?no template}"
    shift

    local xslt='<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    '"${xsl_root_ns_attrs[*]}"'
>
'"$template"'
</xsl:stylesheet>
'

    xsltproc \
        --output "$xml_file" \
       "$@" <(cat - <<< "$xslt") \
       "$xml_file"
}

xpath_stack=()

:xml.push_xpath() {
    if [[ -n "${cur_xpath:-}" ]]; then
        xpath_stack+=("$cur_xpath")
    fi

    declare -g -- cur_xpath="${1:-}"
}

:xml.pop_xpath() {
    if [[ "${#xpath_stack[@]}" -eq 0 ]]; then
        unset cur_xpath
        return 0
    fi

    declare -g -- cur_xpath="${xpath_stack[-1]}"
    unset "xpath_stack[$((${#xpath_stack[@]}-1))]"
}

:xml.edit() {
    xmlstarlet edit --inplace "${xmlstarlet_ns_flags[@]}" \
        ${cur_xpath:+--var 'cur' "$cur_xpath"} \
        "$@" "$xml_file"
}

@xml.query() {
    xmlstarlet select ${__quiet:+--quiet} "${xmlstarlet_ns_flags[@]}" -t \
        ${cur_xpath:+--var 'cur'="$cur_xpath"} \
        "$@" "$xml_file"
}

@xml.query_val() {
    local opts=("${@:1:${#@}-2}")
    local xpath="${*:(-2):1}"
    local var="${*:(-1)}"

    declare -n -- val="$var"

    __quiet=1 @xml.query "${opts[@]}" -c "$xpath" || return 2
    val="$(@xml.query "${opts[@]}" -v "$xpath/@w:val")" || return 1
}

@xml.query_bool() {
    local ret=0

    local var="${*:(-1)}"
    declare -n -- val="$var"

    @xml.query_val "$@" || ret="$?"

    case "$ret" in
        2) val=;;
        1) val=true;;
        0) val="${val:-true}";;
    esac
}

:xml.ensure_subnode() {
    if [[ -n "${__key:-}" ]]; then
        local xml_ensured_var="__xml_ensured_${__key}__"
        [[ "${!xml_ensured_var:-}" != "$cur_xpath" ]] || return 0
        declare -g -- "$xml_ensured_var"="$cur_xpath"
    fi

    local node_name="${1:?no node name}"

    __quiet=1 @xml.query -c "\$cur/$node_name" || {
        local type=elem

        if [[ "${node_name:0:1}" = '@' ]]; then
            type=attr; node_name="${node_name:1}"
        elif [[ "$node_name" = "text()" ]]; then
            type=text; node_name=''
        fi

        :xml.edit -s \$cur -t "$type" -n "$node_name"
    }
}

@xml.query_subnode_attrs() {
    local node_name="${1:?no node name}"
    shift

    declare -n -- attr_map="${__attr_map_name:-__type_${node_name//:/_}__}"

    local query_args=()
    local var_names=()

    local attr_name
    for attr_name in "${!attr_map[@]}"; do
        query_args+=(-v "\$cur/$node_name/@$attr_name" --nl)
        var_names+=("${attr_map[$attr_name]}")
    done

    extract_lines \
        "${var_names[@]}" \
    <(@xml.query "$@" \
        "${query_args[@]}"
    )
}

:xml.recreate_subnode() {
    local node_name="${1:?no node name}"
    shift

    declare -n -- attr_map="${__attr_map_name:-__type_${node_name//:/_}__}"

    if [[ "$#" -gt 0 ]]
    then
        declare -- "$@"
        local __arguments=()
        store_args "${attr_map[@]}"
        declare -- "${__arguments[@]}"
    fi

    local resolver_name="${__resolver_name:-__resolver_${node_name//:/_}__}"
    ! declare -F "$resolver_name" > /dev/null || "$resolver_name"

    :xml.edit -d "\$cur/$node_name"
    if bool "${_unset-0}"; then
        return 0
    fi

    local edit_args=()
    local attr_name var_name

    for attr_name in "${!attr_map[@]}"; do
        var_name="${attr_map[$attr_name]%%[:\?\-]*}"
        edit_args+=(${!var_name+-s "\$__node__" -t attr -n "$attr_name" -v "${!var_name}"})
    done

    :xml.edit -s "\$cur" -t elem -n "$node_name" \
        --var '__node__' "\$prev" \
        "${edit_args[@]}"
}

:xml.flush_ns
