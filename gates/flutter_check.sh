#!/usr/bin/env bash
# flutter_check.sh : Flutter 프로젝트 검증 게이트
#
# 사용법:
#   ./flutter_check.sh          # quick  : analyze + test
#   ./flutter_check.sh standard # standard: analyze + test + build_runner + debug build
#
# 규칙:
# - 이 스크립트의 All PASS 없이 "완료"를 보고하지 않는다
# - All PASS 시 영수증(RECEIPT) 토큰이 발급된다. 완료 보고에는 이 토큰을 인용해야
#   한다. 토큰은 실행해야만 알 수 있으므로 "통과했다"는 말만으로는 보고할 수 없다
# - FAIL이 하나라도 있으면 종료 코드 1. pre-commit 훅과 CI가 이 코드로 차단한다

set -u
MODE="${1:-quick}"
FAIL=0
RECEIPT_DIR=".bridle"
RECEIPT_LOG="$RECEIPT_DIR/receipts.log"

case "$MODE" in
  quick|standard|e2e) ;;
  *)
    echo "지원하지 않는 모드: $MODE (quick, standard, e2e 중 하나를 사용하십시오.)"
    exit 2
    ;;
esac

# 도구 부재와 코드 실패를 구분한다.
# flutter가 없으면 게이트는 "통과"도 "실패"도 아니다. 검증 불가이므로 종료 코드 2로
# 명확히 구분해 종료한다. 통과로 처리하면 도구 없는 CI가 무검증 통과되어 위험하다.
if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter를 찾지 못했습니다. 이 환경에서는 게이트를 실행할 수 없습니다(검증 불가)."
  echo "flutter가 설치된 개발 머신 또는 CI에서 실행하십시오."
  exit 2
fi

run_gate() {
  local name="$1"; shift
  echo "――― [$name] $*"
  if "$@"; then
    echo "PASS [$name]"
    echo ""
    return 0
  else
    echo "FAIL [$name]"
    FAIL=1
    echo ""
    return 1
  fi
}

scan_secrets() {
  local patterns='AIza[0-9A-Za-z_\-]{35}|A(SIA|KIA)[0-9A-Z]{16}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|sk-(proj-)?[A-Za-z0-9_\-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|glpat-[A-Za-z0-9_\-]{20,}|xox[baprs]-[A-Za-z0-9-]{20,}|GOCSPX-[A-Za-z0-9_\-]{20,}'
  local hit=0
  local matched_files
  # 현재 작업 트리의 tracked/untracked 파일을 모두 검사한다. 일치한 값은 출력하지 않는다.
  matched_files="$({
    git grep -IlE "$patterns" -- . ':!gates/flutter_check.sh' 2>/dev/null || true
    while IFS= read -r -d '' file; do
      grep -IlE "$patterns" "$file" 2>/dev/null || true
    done < <(git ls-files --others --exclude-standard -z)
  } | LC_ALL=C sort -u)"
  if [ -n "$matched_files" ]; then
    echo "비밀키 패턴이 포함된 작업 트리 파일 검출:"
    printf '%s\n' "$matched_files"
    echo "값은 안전을 위해 출력하지 않았습니다. 저장소에서 제거하고 키를 재발급할 것"
    hit=1
  fi

  local revisions history_matches
  revisions="$(git rev-list --all 2>/dev/null || true)"
  if [ -n "$revisions" ]; then
    history_matches="$(
      git grep -IlE "$patterns" $revisions -- . ':!gates/flutter_check.sh' \
        2>/dev/null | LC_ALL=C sort -u || true
    )"
    if [ -n "$history_matches" ]; then
      echo "비밀키 패턴이 포함된 Git 이력 파일 검출:"
      printf '%s\n' "$history_matches"
      echo "값은 출력하지 않았습니다. 키를 폐기한 뒤 이력 정리와 강제 푸시가 필요합니다."
      hit=1
    fi
  fi

  # 추적되면 안 되는 파일 검출
  local forbidden_files
  forbidden_files="$(git ls-files | grep -E \
    '(^|/)\.env($|\.)|\.(p8|p12|pem|key|jks|keystore|mobileprovision|provisionprofile)$|(^|/)key\.properties$|(^|/)(service-account|credentials)[^/]*\.json$|(^|/)env/[^/]+\.json$' \
    | grep -Ev '(^|/)\.env\.example$|(^|/)env/example\.json$' || true)"
  if [ -n "$forbidden_files" ]; then
    printf '%s\n' "$forbidden_files"
    echo "비밀 파일이 git 추적에 포함됨. gitignore 처리할 것"
    hit=1
  fi
  return "$hit"
}

echo "flutter_check ($MODE mode)"
echo ""

check_doctags() {
  local script; script="$(git rev-parse --show-toplevel)/gates/doctag.sh"
  if [ ! -x "$script" ]; then
    echo "필수 도구 누락: $script"
    return 1
  fi
  "$script" check
}

check_dupscan() {
  local script; script="$(git rev-parse --show-toplevel)/gates/dupscan.py"
  if [ ! -f "$script" ]; then
    echo "필수 도구 누락: $script"
    return 1
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "필수 도구 누락: python3"
    return 1
  fi
  python3 "$script"
}

check_generated_clean() {
  local changed
  changed="$({
    git diff --name-only -- \
      '*.g.dart' '*.freezed.dart' '*.mocks.dart' 'lib/l10n/generated/**'
    git ls-files --others --exclude-standard -- \
      '*.g.dart' '*.freezed.dart' '*.mocks.dart' 'lib/l10n/generated/**'
  } | LC_ALL=C sort -u)"

  if [ -n "$changed" ]; then
    echo "생성 코드가 소스와 일치하지 않습니다:"
    printf '%s\n' "$changed"
    echo "codegen 결과를 검토하고 함께 커밋하십시오."
    return 1
  fi
}

run_build_gate() {
  local platform_found=0
  if [ "$(uname -s)" = "Darwin" ] && [ -d ios ]; then
    platform_found=1
    run_gate build-ios flutter build ios --debug --no-codesign
  fi
  if [ -d android ]; then
    platform_found=1
    run_gate build-android flutter build apk --debug
  fi
  if [ "$platform_found" -eq 0 ]; then
    echo "FAIL [build] 현재 호스트에서 빌드할 Flutter 플랫폼 디렉터리가 없습니다."
    FAIL=1
    return 1
  fi
}

run_gate secrets scan_secrets
run_gate doctags check_doctags
run_gate dupscan check_dupscan

if [ "$MODE" = "standard" ]; then
  if [ -f l10n.yaml ]; then
    run_gate l10n flutter gen-l10n
  fi
  if grep -q build_runner pubspec.yaml 2>/dev/null; then
    run_gate codegen dart run build_runner build
  fi
  run_gate generated-clean check_generated_clean
fi

run_gate analyze flutter analyze
run_gate test flutter test

if [ "$MODE" = "standard" ]; then
  run_build_gate
fi

if [ "$MODE" = "e2e" ]; then
  # 로컬 전용: 시뮬레이터 또는 실기기 연결 필요. CI에서는 실행하지 않는다
  run_gate e2e patrol test
fi

mkdir -p "$RECEIPT_DIR"

if [ "$FAIL" -eq 0 ]; then
  STATE_HASH="$({
    git write-tree 2>/dev/null || git rev-parse HEAD^{tree}
    git diff --binary -- .
    while IFS= read -r -d '' file; do
      printf '%s\0' "$file"
      git hash-object "$file"
    done < <(git ls-files --others --exclude-standard -z)
  } | git hash-object --stdin)"
  STATE_SHORT="$(printf '%s' "$STATE_HASH" | cut -c1-12)"
  TOKEN="$(date +%Y%m%d-%H%M%S)-$STATE_SHORT-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  echo "$TOKEN PASS $MODE state=$STATE_HASH" >> "$RECEIPT_LOG"
  echo "== All PASS =="
  echo "RECEIPT: $TOKEN"
  echo "(완료 보고에 이 토큰을 인용할 것)"
  exit 0
else
  echo "$(date +%Y%m%d-%H%M%S)-FAIL FAIL $MODE" >> "$RECEIPT_LOG"
  echo "== FAIL: 위 결과를 보고하고, 수정 전까지 완료 보고 금지 =="
  exit 1
fi
