# Google Play Console input assets (v1.0)

## Release handoff

### Current console status

- Developer account: `Seongwoo Do` (`seongwoo@10xkeleton.com`)
- Developer account ID: `4737209074398192496`
- Identity document: uploaded; Google verification is in progress
- Physical Android device verification: pending; the account owner must complete it in the Play Console mobile app
- Contact phone verification: locked until identity verification is approved
- App creation and release upload: locked until the account checks above are complete

### Prepared release

- Bundle: `build/app/outputs/bundle/release/app-release.aab`
- Package: `com.seongwoo.focusmark`
- Version: `1.0.0` (`versionCode 2`)
- Minimum SDK: 24
- Target SDK: 36
- Upload certificate SHA-1: `A2:76:49:7F:D4:CE:25:57:05:86:10:32:83:1D:93:5E:78:B9:1B:F2`
- Upload certificate SHA-256: `D6:85:42:C7:46:44:E6:29:AF:C5:77:A5:DE:B3:2E:00:E6:62:7C:49:16:7D:E3:10:FC:E4:2B:B8:95:F9:C4:A9`
- Upload keystore is stored outside the repository. Its passwords are stored in macOS Keychain service `timebox-mark-android-upload-keystore`.

### Console order after verification

1. Create an app named `Timebox Mark`; select App, Free, and Korean as the default language.
2. Keep Google Play App Signing enabled and upload the prepared AAB to Internal testing.
3. Copy both SHA-1 and SHA-256 from **Setup > App integrity > App signing key certificate** into the Firebase Android app settings. These differ from the upload certificate above.
4. Complete App access, Ads, Content rating, Target audience, Data safety, Foreground service, and privacy policy declarations using this document.
5. Upload the icon, feature graphic, and phone screenshots from `build/google_play_assets/`, then add Korean and English listings.
6. Add the review account below, save the release notes, and start the internal test rollout.

Do not publish a Play-signed build to testers before its app-signing SHA certificates are registered in Firebase. Google sign-in can otherwise reject the installed build even when debug and upload-key builds work.

## Product details

- App name: Timebox Mark
- Package name: `com.seongwoo.focusmark`
- Default language: Korean (`ko-KR`)
- App or game: App
- Free or paid: Free
- Category: Productivity
- Contact email: `seongwoo@10xkeleton.com`
- Contact phone: `+821065233103`
- Website: `https://timebox-mark-prod.web.app/`
- Privacy policy: `https://timebox-mark-prod.web.app/privacy/`
- Account deletion: `https://timebox-mark-prod.web.app/support/#account-deletion`

## Store listing (Korean)

### Short description

내게 맞는 시간 단위로 하루를 계획하고, 지금 해야 할 일에 집중하세요.

### Full description

하루 계획이 실제 행동으로 이어지도록, 시간을 눈에 보이는 블록으로 정리하세요.

Timebox Mark는 오늘의 우선순위와 해야 할 일을 15분, 30분 또는 1시간 단위 타임박스로 배치하고, 현재 시간에 맞춰 실행할 수 있는 시간 관리 앱입니다. 복잡한 입력 과정 없이 하루 계획을 만들고, 진행 중인 블록과 남은 시간을 앱과 Android 알림에서 확인할 수 있습니다.

주요 기능

- 오늘의 최우선 항목, 브레인 덤프, 기억할 일을 날짜별로 관리
- 15분, 30분 또는 1시간 단위 타임박스 생성과 길이 조절
- 카드를 드래그해 시간대와 계획 영역 사이에서 빠르게 재배치
- 현재 시간대와 동기화되는 집중 타이머
- Android 지속 알림으로 현재 작업과 남은 시간 확인
- 블록 시작과 종료를 알려주는 로컬 알림
- 로그인 후 Firebase를 통한 일별 계획 동기화
- 선택한 타임박스를 Google Calendar로 내보내기
- 완료 기록을 날짜별로 확인하는 활동 히스토리

계획은 날짜별로 분리되어 저장됩니다. 전날 끝내지 못한 항목은 필요한 것만 오늘로 가져올 수 있고, 반복되는 일정은 요일과 반복 조건을 지정해 준비할 수 있습니다.

캘린더 연동과 알림은 선택 사항입니다. Timebox Mark는 광고 식별자나 위치 정보를 수집하지 않으며, 사용자가 선택한 계획과 계정 동기화에 필요한 정보만 처리합니다.

## Store listing (English)

### Short description

Plan your day in flexible time boxes and stay with the task at hand.

### Full description

Turn a daily plan into visible blocks you can actually follow.

Timebox Mark helps you organize priorities and tasks into 15-minute, 30-minute, or 1-hour time boxes, then follows the current block in sync with the clock. Build a practical day plan with minimal input and keep the active task and remaining time visible in the app and an Android ongoing notification.

Features

- Date-based top priorities, brain dump items, and reminders
- Time boxes in configurable 15-minute, 30-minute, or 1-hour increments
- Smooth drag and drop across the schedule and planning sections
- Focus tracking synchronized with the current time box
- Android ongoing notification with the active task and remaining time
- Local notifications at the start and end of a block
- Firebase-backed daily plan sync after sign-in
- Export selected time boxes to Google Calendar
- Daily completion history

Calendar access and notifications are optional. Timebox Mark does not collect advertising identifiers or location data and processes only the account and planning data needed for features you choose to use.

## App access for review

- All features require sign-in after onboarding.
- Sign-in method: Email and password
- Review account email: `appreview.timeboxmark@10xkeleton.com`
- Password source: macOS Keychain service `timebox-mark-app-review`
- Instructions: Complete or skip onboarding, choose email sign-in, then use the review account. The account contains sample daily-plan data and does not require an OTP or another device.

Do not commit or paste the review password into this file, source code, CI configuration, or issue trackers.

## Policy answers

- Ads: No
- News app: No
- Government app: No
- Financial features: None
- Health features: None
- COVID-19 features: None
- Target audience: Adults, 18 and over
- Content rating: No violence, sexual content, language, controlled substances, gambling, or user-to-user communication
- User-generated content: Private planning data only; it is not public and cannot be shared with other users
- Remote push notifications: Not used in v1.0
- Foreground service: User-started timebox countdown shown as an ongoing notification

## Data safety answers

- Data encrypted in transit: Yes
- Account deletion available: Yes, in Settings and through the public deletion URL
- Data sold: No
- Data shared for advertising: No
- Email address: Collected, linked to the user, required for account management and app functionality
- Name: Collected only when the identity provider supplies it, linked to the user, used for account management
- User IDs: Collected, linked to the user, required for authentication and cloud sync
- Other user-generated content: Daily priorities, brain dump items, reminders, timebox titles, schedules, and completion state; linked to the user and used for app functionality
- Calendar event data: Processed only when the user requests Google Calendar export; used for app functionality and not sold or used for advertising
- Diagnostics: Not collected in v1.0 because Crashlytics is not enabled
- Location, contacts, photos, browsing history, advertising ID: Not collected

## Release notes (Korean)

첫 번째 공개 테스트 버전입니다.

- 선택 가능한 시간 단위의 타임박스 계획과 집중 추적
- 오늘의 최우선 항목, 브레인 덤프, 기억할 일 관리
- 로그인 기반 일별 계획 동기화
- Google Calendar 내보내기
- 현재 작업과 남은 시간을 표시하는 Android 지속 알림

## Release notes (English)

First public testing release.

- Flexible timebox planning and focus tracking
- Daily priorities, brain dump items, and reminders
- Signed-in daily plan sync
- Google Calendar export
- Android ongoing notification for the active task and remaining time

## Required graphics

- App icon: 512 x 512 PNG, no alpha
- Feature graphic: 1024 x 500 PNG, no alpha
- Phone screenshots: at least 2, 16:9 or 9:16, 320-3840 px per side

Generated upload assets live under `build/google_play_assets/` and are intentionally excluded from Git.
