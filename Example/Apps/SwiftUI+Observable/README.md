# SwiftUI+Observable — @Observable MVVM (iOS 17+)

iOS 17의 Observation 프레임워크 기반 최신 방식. Combine 없이 순수 async/await로만 구성했다.
ViewModel 코어(`Intent` + Task 취소 디바운스)는 SwiftUI+Published와 같고, 상태 노출 방식만 `@Observable`이다.

## 구조

`SearchScreen` 네임스페이스 아래 역할별로 파일을 나눈다.

| 파일 | 역할 |
|---|---|
| `SearchScreen.swift` | 씬 네임스페이스 + `Status` / `Intent` enum + 디바운스 상수 |
| `SearchScreen.Context.swift` | View. 상태를 그리기만 하고, 변경은 전부 `reduce(by:)`로 보낸다 |
| `SearchScreen.Model.swift` | 비즈니스 로직. `search(by:) async -> Result<[User], Status>` — 취소는 `.idle`로 변환 |
| `SearchScreen.ViewModel.swift` | 표시 로직. `Intent`를 받아 디바운스 Task로 검색하고 `private(set)` 상태를 갱신 |

## 바인딩 방식

- `@Observable` ViewModel을 View가 `@State`로 소유한다. 모든 상태 프로퍼티는 `private(set)` —
  View는 읽기만 하고, 변경은 `reduce(by:)`(`.input` / `.dismiss` / `.select`) 하나로만 들어온다. 단방향 흐름.
- `.searchable`은 `Binding(get: input, set: reduce(.input))`으로 잇는다.
- 디바운스 = **Task 취소**: 새 입력마다 이전 `debounceTask`를 취소하고
  `sleep(600ms) + 취소 확인` 후 검색한다. 입력이 직전과 같으면 스킵하고,
  빈 입력은 즉시 rows를 `nil`로 리셋하고 진행 중 요청을 취소한다.
- 취소는 구조적 동시성을 타고 URLSession까지 전파되고, Model이 `CancellationError`를
  `.failure(.idle)`로 변환해 얼럿으로 새지 않는다.
- 내비게이션도 상태: `.select` → `route: Screen?` → View가 `onChange`로 감지해 push.
- 검색 실패 시 **이전 결과를 유지하고 alert만 노출**한다 (`FailurePolicyTests`가 단언).

## 장점

- SwiftUI+Published와 ViewModel 형태가 같아, `ObservableObject` ↔ `@Observable` 차이만 순수하게 비교된다.
- 프로퍼티 단위 갱신이라 ObservableObject 방식보다 불필요한 리렌더가 적다.
- Combine이 필요 없다. `@Published`도, 구독 관리도 없다.
- Task 취소가 네트워크 요청까지 실제로 중단시킨다 — `switchToLatest`가 구독만 끊는 Combine과의 차이.

## 한계

- iOS 17+ 전용.
- `$input` 같은 퍼블리셔가 없어 상태 변화를 스트림으로 구독할 수 없다. 테스트에서
  중간 과정(연속 입력 시 검색 1회)을 확인하려면 저장소 호출 기록 같은 우회가 필요하다.
- 디바운스가 ViewModel 소유라, VM 테스트가 디바운스 경과를 기다리는 `settle()`
  벽시계 대기를 필요로 한다.
- 관찰이 필요 없는 내부 저장 `var`에 `@ObservationIgnored`를 빠뜨리면 불필요한 추적이
  생기는 실수를 하기 쉽다.
