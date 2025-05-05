# shellcheck shell=bash
# shellcheck disable=SC2154

declare -A -- \
    __type_w_spacing__=(
        [w:beforeAutospacing]='_beforeAutospacing'
        [w:afterAutospacing]='_afterAutospacing'
        [w:beforeLines]='_beforeLines'
        [w:afterLines]='_afterLines'
        [w:before]='_before'
        [w:after]='_after'
        [w:line]='_line'
        [w:lineRule]='_lineRule'
    )

declare -A \
    __type_w_contextualSpacing__=(
        [w:val]='_contextual'
    )

__resolver_w_spacing__() {
    resolve_unit _beforeLines L=100
    resolve_unit _afterLines L=100

    local __used_unit

    __used_unit=
    resolve_unit _before pt=20 L=100
    [[ "$__used_unit" != L ]] || _beforeLines="$_before"

    __used_unit=
    resolve_unit _after pt=20 L=100
    [[ "$__used_unit" != L ]] || _afterLines="$_after"

    __used_unit=
    resolve_unit _line pt=20 L=240
    if [[ -z "${_lineRule:-}" ]]; then
        case "${__used_unit:-}" in
            pt) _lineRule=exact;;
            L) _lineRule=auto;;
        esac
    else
        # assert
        # || used unit is not 'L'
        # || used unit is 'L' and line rule is 'auto'
        [[ "${__used_unit:-}" != L || "$_lineRule" = auto ]]
    fi
}

@style.para.spacing() {
    @xml.query_subnode_attrs w:spacing

    ! bool "${_beforeAutospacing:-}" || unset _beforeLines _before
    ! bool "${_afterAutospacing:-}" || unset _afterLines _after

    [[ -z "${_beforeLines:-}" ]] || unset _before
    [[ -z "${_afterLines:-}" ]] || unset _after

    @xml.query_bool "\$cur/w:contextualSpacing" _contextual
}

:style.para.spacing() {
    declare -- "$@"
    :xml.recreate_subnode w:spacing "$@"
    :xml.recreate_subnode w:contextualSpacing "${_contextual:+_contextual=}${_contextual:-_unset=1}"
}

# ---

declare -A -- \
    __type_w_ind__=(
        [w:hangingChars]='_hangingChars'
        [w:firstLineChars]='_firstLineChars'
        [w:startChars]='_startChars'
        [w:endChars]='_endChars'

        [w:hanging]='_hanging'
        [w:firstLine]='_firstLine'
        [w:start]='_start'
        [w:end]='_end'
    )

__resolver_w_ind__() {
    resolve_unit _hangingChars C=100
    resolve_unit _firstLineChars C=100
    resolve_unit _startChars C=100
    resolve_unit _endChars C=100

    local __used_unit

    __used_unit=
    resolve_unit _hanging pt=20 C=100
    [[ "$__used_unit" != C ]] || _hangingChars="$_hanging"

    __used_unit=
    resolve_unit _firstLine pt=20 C=100
    [[ "$__used_unit" != C ]] || _firstLineChars="$_firstLine"

    __used_unit=
    resolve_unit _start pt=20 C=100
    [[ "$__used_unit" != C ]] || _startChars="$_start"

    __used_unit=
    resolve_unit _end pt=20 C=100
    [[ "$__used_unit" != C ]] || _endChars="$_end"
}

@style.para.indenting() {
    @xml.query_subnode_attrs w:ind

    [[ -z "${_hangingChars:-}" ]] || unset _hanging
    [[ -z "${_firstLineChars:-}" ]] || unset _firstLine
    [[ -z "${_startChars:-}" ]] || unset _start
    [[ -z "${_endChars:-}" ]] || unset _end
}

:style.para.indenting() {
    :xml.recreate_subnode w:ind "$@"
}

# ---

#region extends alignment
@style.para.justifying() { @style._.justifying "$@"; }
:style.para.justifying() { :style._.justifying "$@"; }
#endregion

# ---

:style.para.borders:begin() {
    :xml.ensure_subnode w:pBdr
    :xml.push_xpath "$cur_xpath/w:pBdr"
}

#region extends border
@style.para.borders.at() { @style._.borders.at "$@"; }
:style.para.borders.at() { :style._.borders.at "$@"; }
#endregion
