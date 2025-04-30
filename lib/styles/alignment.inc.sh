# shellcheck shell=bash

declare -A -- \
    __type_w_jc__=(
        [w:val]='_to:?no justification'
    )

@style._.justifying() { @xml.query_subnode_attrs w:jc; }
:style._.justifying() { :xml.recreate_subnode w:jc "$@"; }

declare -A -- \
    __type_w_vAlign__=(
        [w:val]='_to:?no alignment'
    )

@style._.aligning() { @xml.query_subnode_attrs w:vAlign; }
:style._.aligning() { :xml.recreate_subnode w:vAlign "$@"; }
