# SwiftUI+Observable — @Observable MVVM (iOS 17+)

iOS 17의 Observation 프레임워크 기반 최신 방식. Combine 없이 순수 async/await로만 구성했다.

## 구조

`SearchScreen` 네임스페이스 아래 역할별로 파일을 나눈다.

| 파일 | 역할 |
|---|---|
| `SearchScreen.swift` | 씬 네임스페이스 + `Status` enum (`.idle` / `.alert`) + 디바운스 상수 |
| `SearchScreen.Context.swift` | View. 상태 렌더 + `.searchable` 바인딩 + `.task(id:)` 디바운스 |
| `SearchScreen.Model.swift` | 비즈니스 로직. `search(by:) async -> Result<[User], Status>` — 취소는 `.idle`로 변환 |
| `SearchScreen.ViewModel.swift` | 표시 로직. Model 결과를 화면 프로퍼티에 반영하는 평범한 async 함수 |

## 바인딩 방식

- `@Observable` ViewModel을 View가 `@State`로 소유하고, `.searchable`은
  `Binding(get:set:)`(또는 `@Bindable`)으로 `input`과 양방향 바인딩한다.
- 디바운스는 View의 `.task(id: viewModel.trimmedInput)` — id가 바뀌면 이전 Task를
  자동 취소하고 새로 시작하므로 `sleep + 취소`가 곧 디바운스이고, id가 트림 기준이라
  `removeDuplicates` 역할까지 겸한다.
- 취소는 구조적 동시성을 타고 URLSession까지 전파되고, Model이 `CancellationError`를
  `.failure(.idle)`로 변환해 얼럿으로 새지 않는다.
- ViewModel의 `search()`는 평범한 async 함수. Task 보관도 구독 관리도 없다.

## 장점

- 네 가지 변형 중 ViewModel이 가장 얇다. 클로저도, 퍼블리셔도, Task 보관도 없다.
- 프로퍼티 단위 갱신이라 ObservableObject 방식보다 불필요한 리렌더가 적다.
- 취소 처리가 공짜다. `.task(id:)`의 자동 취소가 네트워크 요청까지 중단시킨다 —
  `switchToLatest`가 구독만 끊는 Combine과의 차이.

## 한계

- iOS 17+ 전용.
- `$input` 같은 퍼블리셔가 없어, 시간축 로직(디바운스)이 View 쪽으로 이동한다.
  디바운스 정책이 View 소유가 되고, 그 동작은 ViewModel 유닛 테스트 범위 밖이다.
- 관찰이 필요 없는 내부 저장 `var`에 `@ObservationIgnored`를 빠뜨리면 불필요한 추적이
  생기는 실수를 하기 쉽다.
