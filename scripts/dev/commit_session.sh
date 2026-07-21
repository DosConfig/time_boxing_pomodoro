#!/usr/bin/env bash
# 이번 세션 작업을 성격별로 나눠 커밋한다.
# 네 맥에서 실행할 것 (flutter가 있어야 pre-commit 게이트가 통과한다).
#   bash scripts/dev/commit_session.sh
# 각 커밋마다 pre-commit 훅이 analyze+test 게이트를 돌린다. 하나라도 FAIL이면 그 커밋에서 멈춘다.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# 빌드 산출물 추적 해제 (이미 해제됐으면 무시)
git rm -r --cached --quiet ios/build 2>/dev/null || true

# C1. chore: 빌드 산출물 추적 해제 + 생성물 무시
git add .gitignore
git commit -m "chore: stop tracking ios build artifacts and ignore generated files"

# C2. build(ios): patrol UI 테스트 타깃 + 릴리즈 서명 설정
git add ios/Runner.xcodeproj ios/Runner.xcworkspace \
  ios/Runner/Info.plist ios/Runner/PrivacyInfo.xcprivacy \
  ios/Runner/Base.lproj ios/Runner/Assets.xcassets \
  ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig \
  ios/RunnerTests ios/RunnerUITests ios/ExportOptions.app-store.plist
git commit -m "build(ios): add patrol UI test target and release signing config"

# C3. feat: 앱 소스 + 에셋
git add lib assets public
git commit -m "feat: feature modules, timebox board keys, and brand assets"

# C4. test: 단위/위젯/E2E 테스트
git add test integration_test pubspec.yaml pubspec.lock
git commit -m "test: add unit tests and patrol user-journey e2e scenarios"

# C5. ci: 릴리즈 자동화 파이프라인
git add codemagic.yaml .circleci .github gates Gemfile Gemfile.lock \
  .env.example scripts firebase.json firestore.indexes.json firestore.rules \
  ios/fastlane
git commit -m "ci: add release automation, flutter gate, and firebase config"

# C6. docs: 문서
git add README.md docs
git commit -m "docs: add release, testing, and store submission guides"

echo ""
echo "== 완료. 생성된 커밋 =="
git log --oneline -6