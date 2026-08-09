# Crashlytics Monitoring and Alert Policy

이 문서는 Timebox Mark의 Crashlytics 수집 범위, Alert 기준, 장애 대응
순서를 한곳에 고정한다. 목표는 로그를 많이 남기는 것이 아니라, 사용자가
실행 중인 타이머를 잃을 수 있는 문제를 빠르게 발견하고 재현하는 것이다.

## 1. 현재 적용 범위

- Flutter framework에서 처리되지 않은 오류는 fatal로 기록한다.
- Flutter framework 밖에서 발생한 uncaught async 오류도 fatal로 기록한다.
- 앱이 계속 동작할 수 있는 복구/동기화 실패는 non-fatal로 기록한다.
- Android에는 Crashlytics Gradle plugin을 적용한다.
- iOS Release archive에는 dSYM upload build phase를 적용한다.
- Firebase Analytics SDK는 Crash-free users/sessions, release 정보,
  Crashlytics breadcrumb를 제공하기 위해 함께 연결한다.
- Release build에서만 기본 수집한다. 로컬 Debug/Profile은
  `--dart-define=ENABLE_DIAGNOSTICS=true`를 명시한 경우에만 수집한다.
- Firebase Auth UID를 Crashlytics user identifier로 설정하지 않는다.

코드와 각 플랫폼 SDK 연결은 완료됐다. 다만 Firebase 프로젝트에서 Google
Analytics 계정을 새로 만드는 마지막 단계는 계정 위치 선택과 법적 약관 동의가
필요하므로 사용자가 직접 완료해야 한다. 그 전까지 Crashlytics 수집은 가능하지만
Analytics breadcrumb와 세션 기반 지표는 완성된 상태로 간주하지 않는다.

앱 시작점은 Firebase를 한 번 초기화한 뒤 Crashlytics handler를 설치한다.
Firebase 초기화가 실패해도 `NoopAppDiagnostics`로 대체하여 앱 실행 자체는
막지 않는다. Riverpod test에서는 provider의 기본값이 Noop이므로 Firebase
plugin이나 실제 네트워크 없이 기존 unit/widget test를 실행할 수 있다.

## 2. 어떤 정보를 남기는가

| 종류 | 실제 값 | 목적 |
|---|---|---|
| Custom key | `app_lifecycle` | 오류 순간 앱이 foreground/background 중 어디였는지 확인 |
| Custom key | `auth_state` | 로그인/로그아웃 상태에 따른 경로 분리 |
| Custom key | `timer_status` | `idle`, `running`, `paused` 등 실행 상태 확인 |
| Custom key | `timer_phase` | focus/short break/long break 구분 |
| Custom key | `schedule_tracking` | 자동 스케줄 추적 사용 여부 확인 |
| Breadcrumb | `focus_started`, `focus_paused`, `focus_resumed`, `focus_reset` | 오류 직전 타이머 조작 순서 확인 |
| Breadcrumb | `scheduled_focus_started`, `timer_segment_completed` | 자동 전환 경로 확인 |
| Non-fatal reason | `initial_*_restore_failed` | cold launch 복구 중 어느 단계가 실패했는지 확인 |
| Non-fatal reason | `resume_*_failed` | foreground 복귀 시 Native/Live Activity 동기화 실패 확인 |
| Non-fatal reason | `live_activity_*_failed` | push token 등록/삭제/stream 실패 확인 |
| Non-fatal reason | `native_timer_*_stream_failed` | MethodChannel timer stream 실패 확인 |

Crashlytics에는 다음 값을 넣지 않는다.

- 이메일, Firebase UID와 같은 계정 식별자
- 타임박스 제목, Brain Dump, Reminder 같은 사용자 입력 내용
- 인증 token, APNs/Live Activity push token
- 요청/응답 전문이나 Firestore 문서 원문

## 3. Fatal, Non-fatal, Log의 구분

### Fatal

앱 코드가 처리하지 못했고 정상 실행을 더 신뢰할 수 없는 오류다.
`FlutterError.onError`와 `PlatformDispatcher.instance.onError`에서 수집한다.
Crashlytics의 fatal 표시는 "이 오류는 사용자 세션을 중단시킬 수 있다"는
운영 우선순위다.

### Non-fatal

해당 작업은 실패했지만 앱은 fallback 또는 다음 재동기화를 통해 계속 쓸 수
있는 오류다. 예를 들어 foreground 복귀 시 Native timer restore가 한 번
실패했거나 Live Activity token 동기화가 실패한 경우다. 이러한 오류를
삼키기만 하면 현장에서 반복되는 결함을 알 수 없으므로 `reason`을 고정해
기록한다.

### Breadcrumb / Custom key

Breadcrumb는 시간 순서다. `focus_started → app_lifecycle_changed →
resume_native_timer_restore_failed`처럼 오류 직전 행동을 보여준다. Custom key는
오류 순간의 단면이다. 두 가지를 함께 봐야 재현 순서와 당시 상태를 구분할 수
있다.

## 4. Firebase Alert 설정

각 iOS/Android 앱에 다음 기준을 적용한다.

| Alert | 초기 출시 설정 | 의미와 대응 |
|---|---:|---|
| New fatal | Email ON | 새 crash issue가 처음 발생하면 즉시 확인 |
| New non-fatal | Email ON | 초기 출시 동안 복구/동기화 결함을 빠르게 수집. 안정화 후 소음이 크면 OFF 검토 |
| ANR | Email ON (Android) | UI thread가 장시간 멈춘 신규 issue 확인 |
| Regressed | 기본 ON | 해결 처리한 issue가 새 버전에서 다시 발생 |
| Trending | 기본 ON | 기존 issue의 발생 빈도가 평소보다 증가 |
| Velocity | 설정 완료: Email/Console ON, `1% of sessions + 10 users` | 동일 issue가 30분 안에 빠르게 확산될 때 긴급 대응 |

Velocity Alert는 앱별 설정이다. 30분 구간 안에서 비율 기준과 최소 영향 사용자
수를 모두 넘어야 하고, 그 구간의 전체 사용자가 10명 이상이어야 한다. 따라서
출시 초기에 동시 사용자가 10명 미만이면 Velocity가 울리지 않는 것은 설정
실패가 아니다. 이때는 New fatal과 Regressed 알림이 안전망이다. 사용량이
늘고 알림이 과도해지면 최소 영향 사용자를 25명 이상으로 조정한다.

Crash-free users와 Crash-free sessions는 Alert 종류가 아니라 release 품질
지표다. 기본 Crashlytics 설정에는 "Crash-free users가 N% 미만이면 이메일"과
같은 직접 임계치 알림이 없다. 지금 단계에서는 release 후 이 지표를 직접
확인하고, 더 큰 운영 규모에서 필요해지면 BigQuery/Cloud Monitoring 기반의
별도 SLO alert를 만든다.

## 5. Alert를 받았을 때 보는 순서

1. **영향도**: fatal/non-fatal/ANR, 영향 사용자 수, Crash-free users/sessions를
   확인한다.
2. **범위**: 최초 발생 버전, 최근 발생 버전, OS, 기종별 편중을 확인한다.
3. **재현 순서**: breadcrumb에서 lifecycle과 focus 조작 순서를 확인한다.
4. **상태**: `timer_status`, `timer_phase`, `schedule_tracking` key를 확인한다.
5. **코드 위치**: symbolicated stack trace의 첫 application frame부터 본다.
6. **대응 선택**: 사용자 데이터 손실/앱 실행 불가라면 rollout 중지·rollback·
   긴급 binary release를 우선한다. Dart-only이며 Shorebird 정책 범위 안의
   결함만 OTA patch 후보로 본다.
7. **재발 방지**: 재현 test 또는 해당 상태 전이의 unit/widget test를 추가하고,
   수정 버전에서 issue가 종료되는지 확인한다.

## 6. Release 전 검증

```bash
flutter analyze
flutter test
flutter build ios --release --no-codesign
flutter build appbundle --release
```

최초 한 번은 별도 로컬 검증 브랜치에서 Firebase 공식 방식대로 test fatal을
발생시키고, 해당 임시 코드를 바로 제거한 뒤 다음을 확인한다.

- Firebase Crashlytics dashboard에 issue가 도착하는가
- iOS stack trace가 dSYM을 통해 symbolicate되는가
- Android stack trace가 앱 소스 위치를 보여주는가
- release/build version이 올바르게 구분되는가
- custom key와 breadcrumb에 사용자 입력 내용이 포함되지 않았는가
- Firebase Settings > Alerts에서 본인 이메일 channel이 활성화됐는가

Debug build로 전달 경로만 확인하려면 다음 flag로 실행한다.

```bash
flutter run --dart-define=ENABLE_DIAGNOSTICS=true
```

이 flag가 없으면 Debug/Profile build의 Crashlytics와 Analytics 수집은 꺼져
있다. 운영 지표에 개발 중 오류가 섞이지 않게 하기 위한 선택이다.

## 7. 코드 위치

- 초기화와 전역 오류 handler: `lib/shared/diagnostics/app_diagnostics.dart`
- 앱 lifecycle/auth breadcrumb: `lib/main.dart`
- 타이머/Live Activity non-fatal과 상태 breadcrumb:
  `lib/features/focus/presentation/controllers/pomodoro_controller.dart`
- Android plugin: `android/settings.gradle.kts`,
  `android/app/build.gradle.kts`
- iOS dSYM upload phase: `ios/Runner.xcodeproj/project.pbxproj`
