# SwiftUI+Published — ObservableObject MVVM

iOS 17 이전까지 SwiftUI MVVM의 표준이던 방식. `ObservableObject` + `@Published` + `@StateObject` 조합.

## 구조

`SearchScreen` 네임스페이스 아래 역할별로 파일을 나눈다.

| 파일 | 역할 |
|---|---|
| `SearchScreen.swift` | 씬 네임스페이스 + `Status` enum (`.idle` / `.alert`) + 디바운스 상수 |
| `SearchScreen.Context.swift` | View. 상태를 그리기만 한다 |
| `SearchScreen.Model.swift` | 비즈니스 로직. `search(by:) async -> Result<[User], Status>` — Combine 의존 없음 |
| `SearchScreen.ViewModel.swift` | 표시 로직. Combine 파이프라인으로 Model과 View를 잇는다 |

## 바인딩 방식

- `@Published var input`을 View가 `.searchable(text: $viewModel.input)`로 양방향 바인딩한다.
- ViewModel이 자신의 `$input` 퍼블리셔를 구독해 트림 → `removeDuplicates` → 디바운스 후
  검색을 실행한다 — 시간축 로직이 전부 ViewModel 안에 있다.
- 검색 결과는 **`Result<[User], Status>` 값 스트림**으로 흘린다. 에러도 Output 값이라
  실패해도 스트림이 죽지 않고, `switchToLatest`가 항상 최신 요청만 유지하며,
  `successes()` / `failures()`로 갈래를 나눠 `rows`와 얼럿에 각각 바인딩한다.

## 장점

- 바인딩 코드가 거의 없다. `@Published` 변경이 곧 화면 갱신.
- Model이 순수 async 함수라 테스트가 `await` 한 줄로 끝난다.
- 성공/실패가 서로 다른 갈래로 흐르므로 각 처리 위치가 명확하다.
- SwiftUI 수명주기(`.task`)와 결합하면 취소 처리가 공짜로 따라온다.

## 한계

- `objectWillChange` 단위 갱신이라, 프로퍼티 하나만 바뀌어도 이 객체를 관찰하는 모든 View가 다시 계산된다(@Observable과의 핵심 차이).
- `switchToLatest`는 Combine 구독만 취소하고 내부 `Task`(네트워크)까지 중단하지는 않는다.
- `@StateObject`/`@ObservedObject`/`@EnvironmentObject` 선택을 잘못하면 상태가 리셋되는 함정이 있다.
- Combine(파이프라인)과 async/await(Model)가 공존해 흐름이 두 갈래가 된다.
