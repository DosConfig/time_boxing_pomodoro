# App Store Connect 입력 자산 (v1.0)

> 상태 반영: Google/Apple 로그인 + 캘린더 연동 포함, Crashlytics 미포함(결정 대기).
> Crashlytics를 넣기로 하면 개인정보 처리방침의 [진단 데이터] 절과 라벨의 진단 항목을 활성화할 것.

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
- 완료된 타임박스를 캘린더에 기록해 하루가 실제로 어떻게 쓰였는지 확인
- Google 캘린더 연동(선택): 계획한 타임박스를 내 캘린더에 동기화

수집하는 데이터가 거의 없는 가벼운 앱입니다. 캘린더 연동은 선택 사항이며, 연동 시에도 일정 데이터는 사용자의 캘린더에만 기록됩니다.

## Description (English)

Plan your day in time boxes. Run it from your Lock Screen.

Timebox Mark turns a daily timeboxed plan into an executable timer. Start a session and a Live Activity keeps the current box and remaining time visible on the Lock Screen and in the Dynamic Island, so you never need to open the app to stay on track.

Features

- Fixed slot timebox board: plan the whole day in a few taps
- Live Activity on the Lock Screen and Dynamic Island
- Wall clock synced timer that survives app restarts
- Write finished boxes to your calendar to see where the day really went
- Optional Google Calendar sync for your planned boxes

## 키워드

- 한: 뽀모도로,타임박싱,집중,타이머,잠금화면,계획,시간관리,포커스
- 영: pomodoro,timeboxing,focus,timer,lock screen,live activity,planner,deep work

## 카테고리 / 연령

- 기본: 생산성 (보조: 라이프스타일)
- 연령 등급: 4+

## 심사 노트 (Review Notes)

Live Activity is the core feature. To verify: open the app, start any timebox timer, then lock the device. The Live Activity appears on the Lock Screen and in the Dynamic Island. Google sign in is optional and used only to sync the user's own Google Calendar. Sign in with Apple is also provided.

## 개인정보 라벨 (Privacy Nutrition Label)

- 수집 항목
  - 연락처 정보 > 이메일 주소: 로그인 시(Apple/Google), 앱 기능에 사용, 사용자와 연결됨, 추적 아님
  - 사용자 콘텐츠 > 기타(캘린더 일정): 캘린더 연동 사용 시, 앱 기능에 사용, 사용자와 연결됨, 추적 아님
- 미수집: 위치, 검색 기록, 브라우징, 광고 식별자 등 전부 아니오
- (Crashlytics 포함 시) 진단 > 충돌 데이터: 앱 기능에 사용, 사용자와 연결되지 않음

## 개인정보 처리방침 페이지 초안 (10xkeleton.com/privacy 게시용)

Timebox Mark 개인정보 처리방침

시행일: 2026년 7월

Timebox Mark는 개인 개발자가 만든 타임박싱 앱입니다. 앱은 다음 원칙을 따릅니다.

1. 수집하는 정보
- 계정 로그인(선택): Apple 또는 Google 계정으로 로그인하면 이메일 주소와 표시 이름을 받습니다. 이는 캘린더 동기화 기능을 제공하기 위해서만 사용됩니다.
- 캘린더 데이터(선택): 캘린더 연동을 켜면 사용자가 만든 타임박스를 사용자의 캘린더에 기록합니다. 캘린더 데이터는 사용자의 기기와 사용자의 캘린더 제공자(Apple/Google) 사이에서만 이동하며, 개발자 서버로 전송되거나 저장되지 않습니다.
- 타이머와 계획 데이터: 모두 사용자의 기기에만 저장됩니다.

2. Google 사용자 데이터
Timebox Mark의 Google API 사용은 Google API 서비스 사용자 데이터 정책(제한적 사용 요건 포함)을 준수합니다. Google 캘린더 데이터는 캘린더 동기화 기능 제공 외의 목적으로 사용하지 않으며, 광고에 사용하거나 제3자에게 판매, 양도하지 않습니다.

3. 수집하지 않는 정보
위치, 연락처, 사진, 광고 식별자를 수집하지 않으며, 사용자를 추적하지 않습니다.

4. (Crashlytics 포함 시에만) 진단 데이터
앱 안정성 개선을 위해 익명화된 충돌 로그를 수집합니다. 이 데이터는 특정 사용자와 연결되지 않습니다.

5. 문의
qlqjsdmsz8@gmail.com

Privacy Policy (English summary)

Timebox Mark stores your timer and planning data on your device only. Optional sign in (Apple or Google) is used solely to sync your time boxes to your own calendar. Calendar data moves only between your device and your calendar provider and is never sent to or stored on our servers. Use of Google user data complies with the Google API Services User Data Policy, including the Limited Use requirements. We do not collect location, contacts, photos, or advertising identifiers, and we do not track you. Contact: qlqjsdmsz8@gmail.com

## 스크린샷 플랜 (6.7인치 필수, 6.5인치 겸용)

1. 타임박스 보드(오늘 계획) 화면
2. 실행 중 타이머 화면
3. 잠금화면 Live Activity (실기기 캡처 권장)
4. Dynamic Island 확장 상태
5. 캘린더 동기화 화면
