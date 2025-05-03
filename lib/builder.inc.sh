# shellcheck shell=bash

__builder_lvl=-1

,begin() {
  __builder_lvl=$((__builder_lvl + 1))
  [[ -n "${1:-}" ]] || set -- "\$prev_elem"
  __edit_args+=(--var "cur_${__builder_lvl}" "$1")
}

,end() {
  __builder_lvl=$((__builder_lvl - 1))
}

,subnode() {
  local node="${1:?no node}"
  shift

  local type=elem
  local name="${node%%=*}"
  local value="${node:${#name}+1}"

  if [[ "${name:0:1}" = '@' ]]
  then
      type=attr
      name="${name:1}"
  elif [[ "$name" = "text()" ]]
  then
      type=text
      name=''
  fi

  __edit_args+=(-s "\$cur_${__builder_lvl}" -t "$type" -n "$name" ${value:+-v "$value"})
  [[ "$type" != "elem" ]] || __edit_args+=(--var prev_elem "\$prev")

  ,begin
    local sub
    for sub in "$@"; do
      ,subnode "$sub"
    done
  ,end
}
