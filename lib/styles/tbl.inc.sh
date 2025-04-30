# shellcheck shell=bash
# shellcheck disable=SC2154

:style@table:for() {
    local section="${1:?no section}"

    local subnode="w:tblStylePr[@w:type=\"$section\"]"
    __quiet=1 @xml.query -c "\$cur/$subnode" || :xml.edit \
        -s "\$cur" -t elem -n w:tblStylePr --var 'override' "\$prev" \
            -s "\$override" -t attr -n w:type -v "$section"

    :xml.push_xpath "$cur_xpath/$subnode"
}

# ---

#region table borders
:style.table.borders:begin() {
    __key=tbl_bdr :xml.ensure_subnode w:tblBorders
    :xml.push_xpath "$cur_xpath/w:tblBorders"
}

#region extends border
@style.table.borders.at() { @style._.borders.at "$@"; }
:style.table.borders.at() { :style._.borders.at "$@"; }
#endregion

@style.table.border_at() {
    :style.table.borders:begin
        @style.table.borders.at "$@"
    :style:end
}

:style.table.border_at() {
    :style.table.borders:begin
        :style.table.borders.at "$@"
    :style:end
}
#endregion

# ---

#region table cell borders
:style.table_cell.borders:begin() {
    __key=tbl_cell_bdr :xml.ensure_subnode w:tcBorders
    :xml.push_xpath "$cur_xpath/w:tcBorders"
}

#region extends border
@style.table_cell.borders.at() { @style._.borders.at "$@"; }
:style.table_cell.borders.at() { :style._.borders.at "$@"; }
#endregion

@style.table_cell.border_at() {
    :style.table_cell.borders:begin
        @style.table_cell.borders.at "$@"
    :style:end
}

:style.table_cell.border_at() {
    :style.table_cell.borders:begin
        :style.table_cell.borders.at "$@"
    :style:end
}
#endregion

# ---

#region extends alignment
@style.table.justifying() { @style._.justifying "$@"; }
:style.table.justifying() { :style._.justifying "$@"; }

@style.table_row.justifying() { @style._.justifying "$@"; }
:style.table_row.justifying() { :style._.justifying "$@"; }

@style.table_cell.aligning() { @style._.aligning "$@"; }
:style.table_cell.aligning() { :style._.aligning "$@"; }
#endregion
