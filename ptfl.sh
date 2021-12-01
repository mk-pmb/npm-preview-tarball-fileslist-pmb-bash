#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function npm_preview_tarball_fileslist () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local ITEM= RV=
  ITEM="$(npm pack --dry-run 2>&1)"
  RV=$?
  if [ "$RV" != 0 ]; then
    echo "$ITEM" >&2
    echo "E: $FUNCNAME: npm failed, rv=$RV" >&2
    return $RV
  fi

  <<<"$ITEM" sed -nrf <(echo '
    s~\s+$~~
    s~^npm [a-z]+ ~~p
    ') | sed -nrf <(echo '
    : skip
      /^=+ [Tt]arball [Cc]ontents? =+$/{n;b copy}
      n
    b skip
    : copy
      /^=+ /b skip
      p;n
    b copy
    ') | sort --version-sort --key 2 \
    | grep . || return 4$(echo "E: $FUNCNAME: found no files" >&2)
}


[ "$1" == --lib ] && return 0; npm_preview_tarball_fileslist "$@"; exit $?
