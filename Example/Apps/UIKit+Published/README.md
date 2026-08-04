# UIKit+Published — @Published 상태 구독 MVVM

ViewModel이 `@Published` 상태 프로퍼티 하나를 노출하고, ViewController가 직접 구독하는 기본형.

## 바인딩 방식

- ViewModel은 `@Published private(set) var state`가 유일한 출력이다.
- ViewController는 `viewModel.$state.sink { render($0) }`로 바인딩한다.
  `$state`는 구독 시점에 현재 값을 즉시 방출하므로 초기 렌더링도 같은 경로로 처리된다.
- 디바운스는 Task 취소(sleep 후 취소 확인)로 구현 — 연산자 체인 대신 구조적 동시성을 쓴다.
- 화면 전환은 ViewController가 직접 수행하되, 다음 ViewModel 생성은 현재 ViewModel의 팩토리 메서드(`makeDetailViewModel`)에 맡긴다.

## UIKit+Transform과의 차이

같은 Combine이지만 방향이 다르다:

- **UIKit+Published**: ViewModel이 상태를 **소유**하고 밖으로 노출 → View가 구독. 명령형 메서드 호출(`search(query:)`)로 입력 전달.
- **UIKit+Transform**: 입력 스트림을 받아 출력 스트림으로 **변환**(transform). 시간축 로직(디바운스 등)이 전부 파이프라인 안에 있다.

## 장점

- 이해할 개념이 적다. `@Published` + `sink`만 알면 된다.
- 상태가 프로퍼티로 존재하므로 아무 때나 현재 상태를 읽을 수 있고, 테스트에서 `viewModel.state` 단언이 간단하다.

## 한계

- 출력이 여러 개로 늘어나면 `@Published` 프로퍼티가 늘어나며 상태 간 정합성 관리가 번거로워진다.
- 디바운스 같은 시간축 로직을 Task 취소로 수동 구현해야 한다.
