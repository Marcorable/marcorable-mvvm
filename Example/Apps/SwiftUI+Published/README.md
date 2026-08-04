# SwiftUI+Published — ObservableObject MVVM

iOS 17 이전까지 SwiftUI MVVM의 표준이던 방식. `ObservableObject` + `@Published` + `@StateObject` 조합.

## 바인딩 방식

- `@Published var query`를 View가 `.searchable(text: $viewModel.query)`로 양방향 바인딩한다.
- ViewModel이 자신의 `$query` 퍼블리셔를 구독해 디바운스 후 검색을 실행한다.
- 상세 화면은 `func load() async`를 View의 `.task`에서 호출 — View가 사라지면 SwiftUI가 Task를 자동 취소해준다.

## 장점

- 바인딩 코드가 거의 없다. `@Published` 변경이 곧 화면 갱신.
- SwiftUI 수명주기(`.task`)와 결합하면 취소 처리가 공짜로 따라온다.

## 한계

- `objectWillChange` 단위 갱신이라, 프로퍼티 하나만 바뀌어도 이 객체를 관찰하는 모든 View가 다시 계산된다(@Observable과의 핵심 차이).
- `@StateObject`/`@ObservedObject`/`@EnvironmentObject` 선택을 잘못하면 상태가 리셋되는 함정이 있다.
- Combine(디바운스)과 async/await(요청)가 한 클래스에 공존해 흐름이 두 갈래가 된다.
