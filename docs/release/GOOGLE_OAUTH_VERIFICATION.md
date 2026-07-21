# Google OAuth 앱 심사 준비 (calendar.events, sensitive scope)

Timebox Mark는 `https://www.googleapis.com/auth/calendar.events` 스코프 하나만 사용하며, 동작은 사용자의 기본 캘린더에 이벤트를 생성하는 것(`POST /calendars/primary/events`)뿐이다. 읽기, 삭제, 목록 조회는 하지 않는다. 이 문서의 문구는 Google Cloud Console과 Search Console에 그대로 붙여넣는 용도.

준비 순서: (1) Search Console 도메인 인증 → (2) OAuth 동의 화면 완성 → (3) 시연 영상 → (4) Verification Center 제출.

---

## 0. 지금 당장 우회 (심사 전 내부 검증용)

Google Cloud Console > API 및 서비스 > OAuth 동의 화면 > 게시 상태를 **"테스트"**로 두고, 테스트 사용자에 본인/지인 Google 계정을 추가한다. 이러면 경고 없이 최대 100명까지 사용 가능. 정식 출시(불특정 다수) 전에 아래 심사를 완료한다.

---

## 1. Search Console 도메인 인증 (web.app)

OAuth 동의 화면에 넣는 모든 도메인은 Search Console에서 같은 Google 계정으로 소유 확인되어야 한다. 여기서는 `timebox-mark-prod.web.app` 하나.

web.app은 Google 관리 도메인이라 DNS 방식이 안 되므로 **HTML 파일 방식**을 쓴다.

1. Google Search Console(search.google.com/search-console) > 속성 추가 > **URL 접두어** > `https://timebox-mark-prod.web.app` 입력
2. 확인 방법에서 **HTML 파일**을 선택하면 `googleXXXXXXXX.html` 파일을 준다
3. 그 파일을 프로젝트의 `public/` 폴더에 넣고 Firebase 배포:
   ```bash
   # 받은 파일을 public/에 복사한 뒤
   firebase deploy --only hosting
   ```
4. 배포 후 `https://timebox-mark-prod.web.app/googleXXXXXXXX.html`이 열리는지 확인하고 Search Console에서 "확인" 클릭

(대안: `public/index.html`의 `<head>`에 Search Console이 주는 `<meta name="google-site-verification" ...>` 태그를 넣고 배포해도 된다)

---

## 2. OAuth 동의 화면 입력값

Google Cloud Console > API 및 서비스 > OAuth 동의 화면

- User Type: External
- 앱 이름: `Timebox Mark`
- 사용자 지원 이메일: `seongwoo@10xkeleton.com`
- 앱 로고: 512x512 PNG (스토어 아이콘 재사용)
- 앱 홈페이지: `https://timebox-mark-prod.web.app/`
- 개인정보처리방침: `https://timebox-mark-prod.web.app/privacy/`
- 서비스 약관: `https://timebox-mark-prod.web.app/terms/`
- 승인된 도메인: `timebox-mark-prod.web.app`
- 개발자 연락처 이메일: `seongwoo@10xkeleton.com`
- 스코프: `.../auth/calendar.events` 추가 (그 외 민감/제한 스코프 없음)

---

## 3. 스코프 사용 사유 (justification, 그대로 붙여넣기)

영문(Verification Center는 영어 입력 권장):

> Timebox Mark is a timeboxing planner. Users build a daily plan of time blocks, and can optionally export selected time blocks to their own Google Calendar as events. The app requests the `calendar.events` scope solely to create these events in the user's primary calendar via `POST /calendars/primary/events`. The app does not read, list, modify, or delete existing calendar data. Export happens only when the user explicitly taps "Export to Google Calendar" for the blocks they selected. Google user data is used only to provide this export feature, is not shared with third parties, and is not used for advertising, in compliance with the Google API Services User Data Policy including the Limited Use requirements.

국문 참고용(내부):

> Timebox Mark는 타임박싱 플래너입니다. 사용자가 만든 타임박스 중 선택한 항목을 사용자 본인의 Google 캘린더에 이벤트로 내보내는 기능에만 calendar.events 스코프를 사용합니다. 기존 캘린더 데이터의 읽기/수정/삭제는 하지 않으며, 사용자가 명시적으로 내보내기를 실행할 때만 기본 캘린더에 이벤트를 생성합니다.

---

## 4. 시연 영상 스크립트 (YouTube 비공개 링크로 제출)

sensitive 스코프 심사의 필수 요건. 아래 흐름을 화면 녹화로 1~2분 안에 담는다. OAuth 클라이언트 ID가 화면에 보이도록 시작한다.

1. (0:00) 브라우저에 Google Cloud Console의 OAuth 클라이언트 ID 화면을 잠깐 보여줌 (심사자가 앱 동일성 확인)
2. 앱 실행 → 로그인 화면에서 **Google로 로그인** 탭
3. Google 계정 선택 → **캘린더 이벤트 생성 권한 동의** 화면이 뜨는 것을 보여줌 → 허용
4. Today 화면에서 타임박스를 하나 선택 → **Google 캘린더로 내보내기** 실행
5. Google 캘린더 앱/웹을 열어 **방금 만든 이벤트가 생성된 것** 확인
6. (끝) 내레이션 또는 자막으로 "calendar.events 스코프는 사용자가 선택한 타임박스를 기본 캘린더에 이벤트로 생성하는 용도로만 사용됨"을 명시

---

## 5. 개인정보처리방침 요건 (이미 충족)

`public/privacy/index.html`에 다음이 이미 포함되어 있어 별도 수정 불필요:

- Google API Services User Data Policy 준수 + Limited Use 요건 명시
- 수집 항목(이메일, 계획 데이터, 선택적 캘린더 이벤트)과 사용 목적
- 제3자 판매/광고 사용 안 함, 추적 안 함

심사 전 `https://timebox-mark-prod.web.app/privacy/`가 실제로 열리고 위 문구가 보이는지만 확인.

---

## 6. Verification Center 제출

Google Cloud Console > API 및 서비스 > OAuth 동의 화면 > 게시 상태를 **프로덕션**으로 변경 → 확인(verification) 요청 → 위 justification과 시연 영상 링크 제출.

제출이 깔끔하면 약 10일 전후. 반려 시 사유를 고쳐 재제출. 가장 흔한 반려 사유는 (1) 도메인 미인증, (2) 시연 영상에서 스코프 사용이 안 보임, (3) 개인정보처리방침 URL 미접속. 세 개만 확실히 하면 대부분 통과.
