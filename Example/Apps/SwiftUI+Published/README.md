# SwiftUI+Published — ObservableObject MVVM

iOS 17 이전까지 SwiftUI MVVM의 표준이던 방식. `ObservableObject` + `@Published` + `@StateObject` 조합.
시간축 로직(디바운스)은 Combine 파이프라인 대신 **async/await(Task 취소)** 로 구현했다.

## 구조

`SearchScreen` 네임스페이스 아래 역할별로 파일을 나눈다.

| 파일 | 역할 |
|---|---|
| `SearchScreen.swift` | 씬 네임스페이스 + `Status` enum (`.idle` / `.alert`) + 디바운스 상수 |
| `SearchScreen.Context.swift` | View. 상태를 그리기만 하고, 변경은 전부 `reduce(by:)`로 보낸다 |
| `SearchScreen.Model.swift` | 비즈니스 로직. `search(by:) async -> Result<[User], Status>` — 취소는 `.idle`로 변환 |
| `SearchScreen.ViewModel.swift` | 표시 로직. `Intent`를 받아 디바운스 Task로 검색하고 `@Published` 상태를 갱신 |

## 바인딩 방식

- 모든 `@Published` 프로퍼티는 `private(set)` — View는 읽기만 하고, 변경은
  `reduce(by:)`(`.input` / `.dismiss` / `.select`) 하나로만 들어온다. 단방향 흐름.
- `.searchable`은 `Binding(get: input, set: action(.input))`으로 잇는다.
- 디바운스 = **Task 취소**: 새 입력마다 이전 `debounceTask`를 취소하고
  `sleep(600ms) + 취소 확인` 후 검색한다. 트림 결과가 직전과 같으면 스킵
  (`removeDuplicates` 등가), 빈 입력은 즉시 rows를 `nil`로 리셋하고 진행 중 요청을 취소한다.
- 취소는 구조적 동시성을 타고 URLSession까지 전파되고, Model이 `CancellationError`를
  `.failure(.idle)`로 변환해 얼럿으로 새지 않는다.
- 검색 실패 시 **이전 결과를 유지하고 alert만 노출**한다 (`FailurePolicyTests`가 단언).

## 장점

- Combine 없이 `ObservableObject`만으로 구성 — 파이프라인 학습 비용이 없다.
- 상태 변경 진입점이 `reduce(by:)` 하나라 흐름 추적이 쉽다.
- Task 취소가 네트워크 요청까지 실제로 중단시킨다 — `switchToLatest`가 구독만 끊던
  Combine 파이프라인 버전보다 우위인 지점.
- Model이 순수 async 함수라 테스트가 `await` 한 줄로 끝난다.

## 한계

- `objectWillChange` 단위 갱신이라, 프로퍼티 하나만 바뀌어도 이 객체를 관찰하는 모든 View가 다시 계산된다(@Observable과의 핵심 차이).
- `@StateObject`/`@ObservedObject`/`@EnvironmentObject` 선택을 잘못하면 상태가 리셋되는 함정이 있다.
- 디바운스가 ViewModel 소유라, VM 테스트가 디바운스 경과를 기다리는 `settle()`
  벽시계 대기를 필요로 한다.
