#!/usr/bin/env bash
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
TAG_RE='(^|[^A-Za-z])///?[[:space:]]*doc:[[:space:]]*'

usage() { echo "usage: doctag.sh {lookup <doc-path> | check}"; exit 2; }
cmd="${1:-}"; shift || true

case "$cmd" in
  lookup)
    target="${1:-}"; [ -z "$target" ] && usage
    base="${target%%#*}"
    echo "== '$base' 를 근거로 한 기존 구현 =="
    if git grep -nE "///?[[:space:]]*doc:[[:space:]]*$base" -- '*.dart' 2>/dev/null; then
      echo ""
      echo "위 구현이 이미 존재합니다. 새로 만들지 말고 재사용/확장할 것."
    else
      echo "(없음) 이 문서를 근거로 한 기존 구현이 없습니다. 신규 구현 가능."
    fi
    ;;
  check)
    fail=0
    tags="$(git grep -nE "$TAG_RE" -- '*.dart' 2>/dev/null \
      | sed -E "s#^([^:]+:[0-9]+):.*doc:[[:space:]]*#\1|#" )"
    [ -z "$tags" ] && { echo "doc 태그 없음 (검사 대상 없음)"; exit 0; }
    while IFS='|' read -r loc path; do
      [ -z "$path" ] && continue
      base="${path%%#*}"
      base="${base%%[[:space:]]*}"
      case "$base" in http://*|https://*) continue;; esac
      if [ ! -f "$base" ]; then
        echo "FAIL $loc -> 존재하지 않는 문서: $base"
        fail=1
      fi
    done <<EOF
$tags
EOF
    [ "$fail" -eq 0 ] && { echo "doc 태그 검사 통과"; exit 0; }
    exit 1
    ;;
  *) usage ;;
esac
