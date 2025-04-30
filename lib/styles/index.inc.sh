# shellcheck shell=bash

:style:for() {
    local subnode="translate(w:name/@w:val, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"
    :xml.push_xpath "/w:styles/w:style[$subnode = \"$(xml_escape_string "${1,,}")\"]"
}

:style:end() {
    :xml.pop_xpath "$@"
}

:style.create() {
    :xml.proc '
        <xsl:template match="/w:styles">
            <xsl:copy>
                <xsl:copy-of select="@*|node()" />
                '"${1:?no style xml}"'
            </xsl:copy>
        </xsl:template>
    '
}

:style:for_toc() {
    :style:for "TOC $1"
    __quiet=1 @xml.query -c "\$cur" || \
        :style.create '
            <w:style
                w:type="paragraph"
                w:styleId="TOC'"$1"'"
            >
                <w:name w:val="TOC '"$1"'" />
                <w:basedOn w:val="Normal" />
                <w:next w:val="Normal" />
                <w:autoRedefine />
            </w:style>
        '
}

:style:for_tof() {
    :style:for 'Table of Figures'
    __quiet=1 @xml.query -c "\$cur" || \
        :style.create '
            <w:style
                w:type="paragraph"
                w:styleId="TableOfFigures"
            >
                <w:name w:val="Table of Figures" />
                <w:basedOn w:val="Normal" />
                <w:next w:val="Normal" />
            </w:style>
        '
}

:style.ensure_run() { __key=run :xml.ensure_subnode w:rPr; }
:style.ensure_para() { __key=para :xml.ensure_subnode w:pPr; }
:style.ensure_table() { __key=tbl :xml.ensure_subnode w:tblPr; }
:style.ensure_table_row() { __key=tbl_row :xml.ensure_subnode w:trPr; }
:style.ensure_table_cell() { __key=tbl_cell :xml.ensure_subnode w:tcPr; }

# shellcheck disable=SC2154
:style.run:begin() { :style.ensure_run; :xml.push_xpath "$cur_xpath/w:rPr"; }
:style.para:begin() { :style.ensure_para; :xml.push_xpath "$cur_xpath/w:pPr"; }
:style.table:begin() { :style.ensure_table; :xml.push_xpath "$cur_xpath/w:tblPr"; }
:style.table_row:begin() { :style.ensure_table_row; :xml.push_xpath "$cur_xpath/w:trPr"; }
:style.table_cell:begin() { :style.ensure_table_cell; :xml.push_xpath "$cur_xpath/w:tcPr"; }

declare -A -- \
    text_size_map=(
        ["初号"]=42
        ["小初"]=36
        ["一号"]=26
        ["小一"]=24
        ["二号"]=22
        ["小二"]=18
        ["三号"]=16
        ["小三"]=15
        ["四号"]=14
        ["小四"]=12
        ["五号"]=10.5
        ["小五"]=9
        ["六号"]=7.5
        ["小六"]=6.5
        ["七号"]=5.5
        ["八号"]=5
    )

resolve_unit() {
    local var="$1"
    declare -n -- val="$var"
    [[ -n "${val:-}" ]] || return 0
    local unit_pairs=("${@:2}")

    if bool "${__is_text-0}" && [[ -v "text_size_map[$val]" ]]; then
        val="${text_size_map[$val]}pt"
    fi

    local unit_pair
    local unit multiplier
    for unit_pair in "${unit_pairs[@]}"; do
        unit="${unit_pair%=*}"; multiplier="${unit_pair#*=}"
        [[ "${#val}" -gt "${#unit}" && "${val:(-${#unit})}" = "$unit" ]] || continue
        val="$(bc <<< "(${val::(-${#unit})}) * ($multiplier) / 1")"
        [[ ! -v __used_unit ]] || __used_unit="$unit"
        break
    done
}
