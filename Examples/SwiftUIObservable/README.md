# SwiftUIObservable — @Observable MVVM (iOS 17+)

iOS 17의 Observation 프레임워크 기반 최신 방식. Combine 없이 순수 async/await로만 구성했다.

## 바인딩 방식

- `@Observable` ViewModel을 View가 `@State`로 소유한다. 프로퍼티 단위로 관찰이 추적된다.
- 디바운스는 View의 `.task(id: viewModel.query)`가 담당 — 검색어가 바뀌면 SwiftUI가 이전 Task를 취소하고 새로 시작하므로, `sleep + 취소`가 곧 디바운스다.
- ViewModel의 `search()`/`load()`는 평범한 async 함수. Task 관리 코드가 없다.

## 장점

- 네 가지 변형 중 ViewModel이 가장 얇다. 클로저도, 퍼블리셔도, Task 보관도 없다.
- 프로퍼티 단위 갱신이라 ObservableObject 방식보다 불필요한 리렌더가 적다.
- 테스트가 `await viewModel.search()` 한 줄 — 콜백 수집이나 expectation이 필요 없다.

## 한계

- iOS 17+ 전용.
- ObservableObject의 `$query` 같은 퍼블리셔가 없어, 시간축 로직(디바운스)이 View 쪽으로 이동한다. 이를 ViewModel 책임으로 볼지 View 책임으로 볼지는 논쟁거리다.
- `@ObservationIgnored`를 빠뜨리면 의존성까지 관찰 대상이 되는 실수를 하기 쉽다.
