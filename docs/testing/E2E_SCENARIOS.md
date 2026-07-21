# E2E 시나리오 (patrol)

유저 저니 단위로 구성한다. 기능 하나가 도는 것보다 사용자가 가치에 도달하는 경로가 끊기지 않는 것이 보장 대상이다. 실행 환경은 시뮬레이터(테스트 코드 디버깅)와 실기기(판정 기준)이며, 릴리즈 전에는 전 시나리오를 실기기에서 일괄 실행한다.

## 원칙

- 저니의 행동은 실제 UI로 진행한다 (버튼 탭, 텍스트 입력). 파인더는 ValueKey와 위젯 타입 사용, 텍스트 파인더 금지 (locale 의존)
- 실 로그인과 실 DB 접근 금지. 인증은 FakeAuthRepository, Firestore는 FakeCloudDataSource로 차단 (integration_test/helpers/e2e_fakes.dart). 실 로그인은 별도 얇은 시나리오로 분리
- 저니 밖의 준비 상태는 SharedPreferences 초기값과 provider override로 주입한다
- 테스트용 Key 규칙: 슬롯 `timebox_slot_<시작분>`, 그 외 `intro_next`, `onboarding_complete`, `timebox_title_field`, `timebox_save`, `start_focus`

## 저니

| ID | 파일 | 경로 | 상태 |
|----|------|------|------|
| J1 | first_day_journey_test.dart | 설치 → 인트로 → 로그인(실 버튼 탭) → 온보딩 → 타임박스 UI 생성 → 집중 시작 | 구현됨, 실행 대기 |
| J2 | timebox_focus_flow_test.dart | 타임박스 실행 → 앱 재실행 → 벽시계 기준 타이머 복원 | 구현됨, 실행 대기 |
| J3 | (예정) planning_journey_test.dart | 브레인덤프 추가 → 리마인더 승격 → 우선순위 지정 → 다음날 carry over | 예정 |
| J4 | (예정) calendar_export_test.dart | 타임박스 선택 → 캘린더 내보내기 → 권한 다이얼로그 수락($.native) → 성공 확인 | 예정 |

## 보조 시나리오 (기술 스모크)

| 파일 | 검증 | 상태 |
|------|------|------|
| app_smoke_test.dart | 첫 실행 인트로 표시 (무주입, main 경로) | 통과 |
| signed_in_shell_test.dart | 로그인 주입 쉘 진입 + 백그라운드 복귀 생존 | 시뮬레이터 통과 |
| (보류) real_sign_in_test.dart | 실 로그인 1개. 테스트 계정 정책 결정 필요 | 보류 |
| (후보) | 타이머 일시정지 → 재실행 복원, 리셋, awake window 변경 반영 | 후보 |

## Live Activity 검증 전략 (3단)

잠금화면과 Dynamic Island는 iOS 시스템 UI라 patrol이 직접 확인하는 것을 보장할 수 없다.

1. 자동(확실): 집중 시작 시 LA 시작 요청이 성공하는지, 요청 내용이 앱 상태와 일치하는지 검증
2. 자동(실험): patrol 네이티브 쿼리로 시스템 화면에서 LA 요소가 잡히는지 실험. 잡히면 채택, 안 잡히면 폐기
3. 수동(체크리스트): 잠금화면 표시, Dynamic Island 확장, 시간 정확성은 릴리즈 전 실기기 수동 확인 항목으로 관리

## 알려진 제약

- 보드 슬롯은 awake window 안에만 존재한다. J1은 온보딩 직후 saveAwakeWindow(0, 1440)으로 하루 전체를 열어 실행 시각과 무관하게 통과하도록 처리했다 (실제 22시 실행에서 슬롯 부재로 실패했던 사례의 재발 방지). 새 저니를 만들 때도 현재 슬롯을 쓰면 같은 처리가 필요하다
- 슬롯 경계 직전(잔여 수 초)에 실행하면 대기 중 슬롯이 끝나 드물게 실패할 수 있다. 재실행으로 해소
- 통과한 실행의 화면 녹화를 보려면 스킴의 attachment 보존 설정이 필요하다 (적용됨, xcresult를 Xcode로 열어 확인)

## 실행

```bash
patrol test                                           # 전체
patrol test --target integration_test/<파일>           # 개별
patrol test --target integration_test/<파일> --release  # 실기기
```
