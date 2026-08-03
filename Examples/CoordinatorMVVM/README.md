# CoordinatorMVVM — MVVM-C

바인딩은 UIKitClosure와 동일하지만, **화면 전환의 책임을 Coordinator로 분리**한 변형.

## 구조

- `AppCoordinator`가 화면 전환의 유일한 주인. 씬(ViewModel + ViewController) 생성과 push를 전부 담당한다.
- ViewModel은 `onUserSelected` 같은 **내비게이션 이벤트만 방출**하고, 다음 화면이 무엇인지 모른다.
- ViewController도 다음 화면을 모른다 — `viewModel.didSelect(user:)`를 호출할 뿐이다.

UIKitClosure와 나란히 놓고 `SearchViewController.didSelectRowAt`과 `SearchViewModel`을 비교해보면 차이가 가장 잘 보인다.

## 장점

- 화면 전환 로직이 한곳에 모여, 딥링크·플로우 재사용·A/B 분기 같은 요구에 강하다.
- 씬들이 서로를 몰라 결합도가 낮다. 어떤 화면이든 어떤 흐름에도 끼워 넣을 수 있다.
- 흐름이 늘어나면 자식 Coordinator로 계층화할 수 있다.

## 한계

- 화면 두 개짜리 앱에는 명백한 오버엔지니어링 — 구조 비용이 이득보다 크다.
- Coordinator의 수명 관리(자식 보관/해제)를 직접 해야 하며, 놓치면 메모리 릭이나 이벤트 유실로 이어진다.
