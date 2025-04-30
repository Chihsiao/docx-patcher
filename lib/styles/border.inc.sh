# shellcheck shell=bash

declare -A -- \
    __type_w_border__=(
        [w:val]='_type:?no type'
        [w:color]='_color:-auto'
        [w:shadow]='_shadow:-'
        [w:space]='_space:-0'
        [w:sz]='_size:-'
    )

__resolver_w_border__() {
    resolve_unit _space pt=1
    resolve_unit _size pt=8
}

@style._.borders.at() {
    local position="${1:?no position}"
    shift

    __attr_map_name=__type_w_border__ \
        @xml.query_subnode_attrs "w:$position"
}

:style._.borders.at() {
    local position="${1:?no position}"
    shift

    __attr_map_name=__type_w_border__ \
    __resolver_name=__resolver_w_border__ \
        :xml.recreate_subnode "w:$position" "$@"
}
