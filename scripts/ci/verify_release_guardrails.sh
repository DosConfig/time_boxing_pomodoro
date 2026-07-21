#!/usr/bin/env bash
# 릴리즈 가드레일. 공통 검증(secrets 패턴 + analyze + test)은 하네스 게이트
# gates/flutter_check.sh 한 곳에서 수행하고, 여기서는 배포 전용 검사만 얹는다.
# (중복구현 방지: analyze/test/시크릿 패턴을 여기 다시 쓰지 않는다)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# 1) 프로젝트 정책(하네스보다 엄격): 자격 파일은 추적 자체를 금지한다.
#    이 저장소는 firebase_options.dart 등을 gitignore하고 CI에서 복원한다.
tracked_secret_paths="$(
  git ls-files | rg \
    '(GoogleService-Info\.plist|google-services\.json|firebase_options\.dart|Firebase\.local\.xcconfig|\.p8$|\.p12$|\.mobileprovision$|\.provisionprofile$|\.jks$|\.keystore$)' || true
)"
if [[ -n "$tracked_secret_paths" ]]; then
  echo "Release guard failed: credential-like files are tracked:" >&2
  echo "$tracked_secret_paths" >&2
  exit 1
fi

# 2) 공통 검증(시크릿 패턴 + analyze + test)은 하네스 게이트에 위임
bash gates/flutter_check.sh quick

# 3) 배포 전용 검사: plist/JSON 유효성 + 법적 링크 존재
plutil -lint \
  ios/Runner/Info.plist \
  ios/Runner/Runner.entitlements \
  ios/Runner/PrivacyInfo.xcprivacy \
  ios/ExportOptions.app-store.plist

python3 -m json.tool firebase.json >/dev/null
python3 -m json.tool firestore.indexes.json >/dev/null

rg -q 'https://timebox-mark-prod\.web\.app/privacy/' lib docs public
rg -q 'https://timebox-mark-prod\.web\.app/support/' lib docs public
rg -q 'https://timebox-mark-prod\.web\.app/terms/' lib docs public
