# shellcheck shell=bash

declare -A -- \
    __type_w_b__=([w:val]='_bold') \
    __type_w_bCs__=([w:val]='_csBold')

@style.run.bold() {
    @xml.query_bool "\$cur/w:b" _bold
    @xml.query_bool "\$cur/w:bCs" _csBold
}

:style.run.bold() {
    declare -- "$@"

    :xml.recreate_subnode w:b "$@"
    local _csBold="${_csBold:-${_bold:-}}"
    :xml.recreate_subnode w:bCs "$@"
}

# ---

declare -A -- \
    __type_w_i__=([w:val]='_italic') \
    __type_w_iCs__=([w:val]='_csItalic')

@style.run.italic() {
    @xml.query_bool "\$cur/w:i" _italic 
    @xml.query_bool "\$cur/w:iCs" _csItalic
}

:style.run.italic() {
    declare -- "$@"

    :xml.recreate_subnode w:i "$@"
    local _csItalic="${_csItalic:-${_italic:-}}"
    :xml.recreate_subnode w:iCs "$@"
}

# ---

declare -A -- \
    __type_w_sz__=([w:val]='_size') \
    __type_w_szCs__=([w:val]='_csSize')

__resolver_w_sz__() { __is_text=1 resolve_unit _size pt=2; }
__resolver_w_szCs__() { __is_text=1 resolve_unit _csSize pt=2; }

@style.run.font_size() {
    @xml.query_subnode_attrs w:sz
    @xml.query_subnode_attrs w:szCs
}

:style.run.font_size() {
    declare -- "$@"

    :xml.recreate_subnode w:sz "$@"
    local _csSize="${_csSize:-${_size:-}}"
    :xml.recreate_subnode w:szCs "$@"
}

# ---

declare -A -- \
    __type_w_rFonts__=(
        [w:ascii]='_asciiFont'
        [w:eastAsia]='_eastAsiaFont'
        [w:hAnsi]='_hAnsiFont'
        [w:cs]='_csFont'
    )

__resolver_w_rFonts__() {
    _asciiFont="${_asciiFont:-${_hAnsiFont:-}}"
}

@style.run.font_family() { @xml.query_subnode_attrs w:rFonts; }
:style.run.font_family() { :xml.recreate_subnode w:rFonts "$@"; }

# ---

declare -A -- \
    __type_w_caps__=([w:val]='_caps') \
    __type_w_smallCaps__=([w:val]='_smallCaps')

@style.run.capital() {
    @xml.query_bool "\$cur/w:caps" _caps
    @xml.query_bool "\$cur/w:smallCaps" _smallCaps
}

:style.run.capital() {
    :xml.recreate_subnode w:caps "$@"
    :xml.recreate_subnode w:smallCaps "$@"
}
