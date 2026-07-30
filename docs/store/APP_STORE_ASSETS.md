# App Store Connect 입력 자산 (v1.0)

> 상태 반영: Google/Apple 로그인 + 캘린더 연동 + Firebase
> Crashlytics/Analytics 포함. 계정 ID와 사용자 입력 계획은 진단 로그에서 제외.

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
- 선택한 타임박스를 Apple 캘린더 또는 Google 캘린더에 이벤트로 내보내기

광고 추적 없이 기능과 안정성에 필요한 데이터만 사용하는 앱입니다. 캘린더
연동은 선택 사항이며, 연동 시에도 일정 데이터는 사용자의 캘린더에만
기록됩니다.

## Description (English)

Plan your day in time boxes. Run it from your Lock Screen.

Timebox Mark turns a daily timeboxed plan into an executable timer. Start a session and a Live Activity keeps the current box and remaining time visible on the Lock Screen and in the Dynamic Island, so you never need to open the app to stay on track.

Features

- Fixed slot timebox board: plan the whole day in a few taps
- Live Activity on the Lock Screen and Dynamic Island
- Wall clock synced timer that survives app restarts
- Firebase-backed daily plan sync after sign-in
- Export selected time boxes to Apple Calendar or Google Calendar

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

Live Activity is the core feature. To verify: sign in, add a timebox for the current 30-minute slot on Today, tap Start Focus, then lock the device. The Live Activity appears on the Lock Screen and in the Dynamic Island. Apple Calendar export is requested only when exporting timeboxes. Google Calendar export uses Google permission to create events in the user's primary calendar. Sign in with Apple and Google sign-in are both provided.

## 개인정보 라벨 (Privacy Nutrition Label)

- 수집 항목
  - 연락처 정보 > 이메일 주소: 로그인 시(Apple/Google), 앱 기능에 사용, 사용자와 연결됨, 추적 아님
  - 사용자 콘텐츠 > 기타 사용자 콘텐츠: 브레인 덤프, 리마인더, 우선순위, 타임박스 계획을 Firebase 동기화에 사용, 사용자와 연결됨, 추적 아님
  - 사용자 콘텐츠 > 캘린더 일정: 캘린더 내보내기 사용 시, 앱 기능에 사용, 사용자와 연결됨, 추적 아님
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
- 계정 로그인: Apple 또는 Google 계정으로 로그인하면 이메일 주소와 표시 이름을 받을 수 있습니다. 이는 인증, 오늘 계획 동기화, 캘린더 제공자 연결을 위해 사용됩니다.
- 계획 데이터: 브레인 덤프, 리마인더, 우선순위, 타임박스 제목/시간, 완료 수는 기기에 저장되며, 로그인 상태에서는 Firebase Firestore에 저장되어 동기화될 수 있습니다.
- 캘린더 데이터(선택): 캘린더 내보내기를 실행하면 사용자가 선택한 타임박스를 사용자의 Apple/Google 캘린더에 이벤트로 추가합니다.

2. Google 사용자 데이터
Timebox Mark의 Google API 사용은 Google API 서비스 사용자 데이터 정책(제한적 사용 요건 포함)을 준수합니다. Google 캘린더 데이터는 캘린더 동기화 기능 제공 외의 목적으로 사용하지 않으며, 광고에 사용하거나 제3자에게 판매, 양도하지 않습니다.

3. 수집하지 않는 정보
위치, 연락처, 사진, 광고 식별자를 수집하지 않으며, 사용자를 추적하지 않습니다.

4. 진단 및 분석 데이터
앱 안정성 개선을 위해 Firebase Crashlytics와 Analytics를 사용합니다. Stack
trace, 앱/OS/기기 버전, 앱 lifecycle 및 timer 상태, Firebase가 생성한
installation/session 식별자와 오류 직전의 제한된 동작 event가 수집될 수
있습니다. 이메일, 계정 ID, 타임박스 제목, Brain Dump/Reminder 텍스트,
인증 token과 Live Activity push token은 진단 로그에 넣지 않습니다. 광고나
cross-app tracking에는 사용하지 않습니다.

5. 문의
seongwoo@10xkeleton.com

Privacy Policy (English summary)

Timebox Mark stores timer and planning data on your device and may sync daily plans through Firebase after sign-in. Sign in with Apple or Google is used for authentication, plan sync, and calendar provider connection. Calendar export creates only the events you choose to export. Firebase Crashlytics and Analytics collect crash, device/app version, installation/session, and limited interaction data for stability; account IDs and user-entered plan text are excluded from diagnostics. Use of Google user data complies with the Google API Services User Data Policy, including the Limited Use requirements. We do not collect location, contacts, photos, or advertising identifiers, and we do not track you. Contact: seongwoo@10xkeleton.com

## 스크린샷 플랜 (6.7인치 필수, 6.5인치 겸용)

1. 타임박스 보드(오늘 계획) 화면
2. 실행 중 타이머 화면
3. 잠금화면 Live Activity (실기기 캡처 권장)
4. Dynamic Island 확장 상태
5. 캘린더 동기화 화면
