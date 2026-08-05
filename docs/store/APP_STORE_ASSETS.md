# App Store Connect 입력 자산 (v1.0)

> 상태 반영: iOS 첫 심사 버전 `1.0.0+13`.
> Google/Apple 로그인 + Firebase + Live Activity + Crashlytics/Analytics 포함.
> 캘린더 기능과 캘린더 권한은 첫 심사 범위에서 제외.

## 앱 이름 / 부제

- 이름: Timebox Mark
- 부제(한): 잠금화면에서 살아있는 타임박스 타이머
- Subtitle(영): Timeboxing that lives on your Lock Screen

## 설명 (한국어)

하루를 타임박스로 계획하고, 잠금화면에서 실행하세요.

Timebox Mark는 오늘의 계획을 실행 가능한 타이머로 바꾸는 타임박싱 앱입니다. 타이머를 시작하면 잠금화면과 Dynamic Island에 Live Activity로 진행 상황이 표시되어, 앱을 열지 않아도 지금 해야 할 일과 남은 시간이 항상 보입니다.

주요 기능

- 고정 슬롯 타임박스 보드로 하루 계획을 몇 번의 탭으로 완성
- 잠금화면 Live Activity와 Dynamic Island로 진행 중인 타임박스 상시 표시
- 벽시계 기준 동기화로 앱을 껐다 켜도 어긋나지 않는 타이머
- Firebase 기반 오늘 계획 동기화로 로그인 후 계획과 진행 상태 복원
- 집중 및 휴식 구간이 끝났을 때 알려주는 로컬 알림

광고 추적 없이 기능과 안정성에 필요한 데이터만 사용하는 앱입니다.

## Description (English)

Plan your day in time boxes. Run it from your Lock Screen.

Timebox Mark turns a daily timeboxed plan into an executable timer. Start a session and a Live Activity keeps the current box and remaining time visible on the Lock Screen and in the Dynamic Island, so you never need to open the app to stay on track.

Features

- Fixed slot timebox board: plan the whole day in a few taps
- Live Activity on the Lock Screen and Dynamic Island
- Wall clock synced timer that survives app restarts
- Firebase-backed daily plan sync after sign-in
- Restore today's plan and progress after sign-in

## 키워드

- 한: 뽀모도로,타임박싱,집중,타이머,잠금화면,계획,시간관리,포커스
- 영: pomodoro,timeboxing,focus,timer,lock screen,live activity,planner,deep work

## 카테고리 / 연령

- 기본: 생산성 (보조: 라이프스타일)
- 연령 등급: 4+
- 개인정보 처리방침 URL: https://timebox-mark-prod.web.app/privacy/
- 지원 URL: https://timebox-mark-prod.web.app/support/
- 이용약관 URL: https://timebox-mark-prod.web.app/terms/

## 심사 노트 (Review Notes)

Live Activity is the core feature. To verify: sign in with Apple or Google, add a timebox that includes the current time on Today, tap Start Focus, then lock the device. The Live Activity appears on the Lock Screen and in the Dynamic Island on supported devices. Local notification permission is requested when the user starts a timer. Calendar access is not included in this version. Account deletion is available in Settings > Account > Delete account.

## 개인정보 라벨 (Privacy Nutrition Label)

- 수집 항목
  - 연락처 정보 > 이메일 주소: 로그인 시(Apple/Google), 앱 기능에 사용, 사용자와 연결됨, 추적 아님
  - 사용자 콘텐츠 > 기타 사용자 콘텐츠: 브레인 덤프, 리마인더, 우선순위, 타임박스 계획을 Firebase 동기화에 사용, 사용자와 연결됨, 추적 아님
- 미수집: 위치, 검색 기록, 브라우징, 광고 식별자 등 전부 아니오
- 진단 > 충돌 데이터: 앱 기능/분석에 사용, 사용자와 연결되지 않음, 추적 아님
- 사용 데이터 > 제품 상호작용: 제한된 lifecycle/screen/timer event를
  장애 재현 및 release 안정성 분석에 사용, 사용자와 연결되지 않음, 추적 아님
- 식별자 > 기기 ID: Firebase installation/session 식별자를 안정성 지표에
  사용, 계정과 연결하지 않음, 추적 아님

## 개인정보 처리방침 페이지

- 공개 URL: https://timebox-mark-prod.web.app/privacy/
- 지원 URL: https://timebox-mark-prod.web.app/support/
- 이용약관 URL: https://timebox-mark-prod.web.app/terms/

아래 내용은 Firebase Hosting에 배포된 페이지와 같은 정책을 따릅니다.

Timebox Mark 개인정보 처리방침

시행일: 2026년 7월

Timebox Mark는 개인 개발자가 만든 타임박싱 앱입니다. 앱은 다음 원칙을 따릅니다.

1. 수집하는 정보
- 계정 로그인: Apple 또는 Google 계정으로 로그인하면 이메일 주소와 표시 이름을 받을 수 있습니다. 이는 인증과 오늘 계획 동기화를 위해 사용됩니다.
- 계획 데이터: 브레인 덤프, 리마인더, 우선순위, 타임박스 제목/시간, 완료 수는 기기에 저장되며, 로그인 상태에서는 Firebase Firestore에 저장되어 동기화될 수 있습니다.
2. 수집하지 않는 정보
위치, 연락처, 사진, 광고 식별자를 수집하지 않으며, 사용자를 추적하지 않습니다.

3. 진단 및 분석 데이터
앱 안정성 개선을 위해 Firebase Crashlytics와 Analytics를 사용합니다. Stack
trace, 앱/OS/기기 버전, 앱 lifecycle 및 timer 상태, Firebase가 생성한
installation/session 식별자와 오류 직전의 제한된 동작 event가 수집될 수
있습니다. 이메일, 계정 ID, 타임박스 제목, Brain Dump/Reminder 텍스트,
인증 token과 Live Activity push token은 진단 로그에 넣지 않습니다. 광고나
cross-app tracking에는 사용하지 않습니다.

4. 문의
seongwoo@10xkeleton.com

Privacy Policy (English summary)

Timebox Mark stores timer and planning data on your device and may sync daily plans through Firebase after sign-in. Sign in with Apple or Google is used for authentication and plan sync. Firebase Crashlytics and Analytics collect crash, device/app version, installation/session, and limited interaction data for stability; account IDs and user-entered plan text are excluded from diagnostics. We do not collect location, contacts, photos, calendar events, or advertising identifiers, and we do not track you. Contact: seongwoo@10xkeleton.com

## 스크린샷 플랜 (6.7인치 필수, 6.5인치 겸용)

1. 타임박스 보드(오늘 계획) 화면
2. 실행 중 타이머 화면
3. 잠금화면 Live Activity (실기기 캡처 권장)
4. Dynamic Island 확장 상태
5. 설정 및 계정 삭제 화면
