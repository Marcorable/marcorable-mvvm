# SwiftUI+Published — ObservableObject MVVM

iOS 17 이전까지 SwiftUI MVVM의 표준이던 방식. `ObservableObject` + `@Published` + `@StateObject` 조합.

## 구조

`SearchScreen` 네임스페이스 아래 역할별로 파일을 나눈다.

| 파일 | 역할 |
|---|---|
| `SearchScreen.swift` | 씬 네임스페이스 + `State` enum (`.idle` / `.alert`) |
| `SearchScreen.Context.swift` | View. 상태를 그리기만 한다 |
| `SearchScreen.Model.swift` | 비즈니스 로직. `search(by:) async -> Result<[User], State>` — Combine 의존 없음 |
| `SearchScreen.ViewModel.swift` | 표시 로직. Combine 파이프라인으로 Model과 View를 잇는다 |
| `Subview/SearchScreen.Row.swift` | 행 View + 행 표시 모델 |

## 바인딩 방식

- `@Published var input`을 View가 `.searchable(text: $viewModel.input)`로 양방향 바인딩한다.
- ViewModel이 자신의 `$input` 퍼블리셔를 구독해 트림 → `removeDuplicates` → 디바운스(400ms) 후 검색을 실행한다.
- 검색 결과는 **`Result<[User], State>` 값 스트림**으로 흘린다. 에러를 Failure 채널이 아닌
  Output 값으로 전달하므로, 실패해도 스트림이 종료되지 않는다.
- `map` + `switchToLatest`로 항상 최신 요청만 유지한다 — 이전 검색의 늦은 응답이
  최신 결과를 덮어쓰는 경쟁이 없다.
- `share()` 뒤에서 SharedKit의 `successes()` / `failures()` 확장으로 성공/실패 갈래를 나눠
  각각 `rows`와 `presentedAlertString`에 바인딩한다. `isLoading`은 `$rows` 파생 스트림과
  실패 갈래가 나눠 끈다.
- 검색 실패 시 **이전 결과를 유지하고 alert만 노출**한다 (의도된 UX —
  `SearchScreen.FailurePolicyTests`가 이 정책을 단언한다).
- 상세 화면은 `func load() async`를 View의 `.task`에서 호출 — View가 사라지면 SwiftUI가 Task를 자동 취소해준다.

## 장점

- 바인딩 코드가 거의 없다. `@Published` 변경이 곧 화면 갱신.
- Model이 순수 async 함수라 테스트가 `await` 한 줄로 끝난다.
- 성공/실패가 서로 다른 갈래로 흐르므로 각 처리 위치가 명확하다.
- SwiftUI 수명주기(`.task`)와 결합하면 취소 처리가 공짜로 따라온다.

## 한계

- `objectWillChange` 단위 갱신이라, 프로퍼티 하나만 바뀌어도 이 객체를 관찰하는 모든 View가 다시 계산된다(@Observable과의 핵심 차이).
- 화면 상태가 `rows` / `isLoading` / `presentedAlertString` 세 프로퍼티로 분산된다 —
  단일 `enum State`로 모으는 다른 세 변형과 비교해볼 지점.
- `switchToLatest`는 Combine 구독만 취소하고 내부 `Task`(네트워크)까지 중단하지는 않는다.
- `@StateObject`/`@ObservedObject`/`@EnvironmentObject` 선택을 잘못하면 상태가 리셋되는 함정이 있다.
- Combine(파이프라인)과 async/await(Model)가 공존해 흐름이 두 갈래가 된다.
