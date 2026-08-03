# UIKitClosure — 클로저 바인딩 MVVM

외부 라이브러리 없이 MVVM의 최소 구조를 보여주는 기본형.

## 바인딩 방식

- ViewModel이 `onStateChange: ((State) -> Void)?` 클로저 하나로 상태를 통지한다.
- ViewController는 `viewDidLoad`에서 클로저를 연결하고, `render(_:)` 하나로 모든 상태를 그린다.
- 화면 전환은 ViewController가 직접 수행하되, 다음 ViewModel 생성은 현재 ViewModel의 팩토리 메서드(`makeDetailViewModel`)에 맡긴다.

## 장점

- 이해해야 할 개념이 가장 적다. 의존성 없음.
- 상태가 `State` enum 하나로 모여 있어 화면 상태의 전체 경우를 컴파일러가 강제한다.

## 한계

- 출력 채널이 여러 개로 늘어나면 클로저가 늘어나며 관리가 번거로워진다.
- 디바운스 같은 스트림 연산을 Task 취소로 수동 구현해야 한다.
- 클로저 순환 참조(`[weak self]`)를 항상 직접 신경 써야 한다.
