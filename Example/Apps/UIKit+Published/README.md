# UIKit+Published — @Published 상태 구독 MVVM

ViewModel이 `@Published` 상태 프로퍼티들을 노출하고 ViewController가 직접 구독하는 기본형.
SwiftUI+Published와 **같은 ViewModel 코어**(`Intent` + Task 취소 디바운스)를 UIKit 바인딩으로 소비한다.

## 구조

| 파일 | 역할 |
|---|---|
| `SearchScreen.swift` | 씬 네임스페이스 + `Status` / `Intent` enum + `IntentSubject` typealias + 디바운스 상수 |
| `SearchScreen.Context.swift` | UITableView 서브클래스. diffable 셀(`UIHostingConfiguration`으로 `AsyncImageLabelRow` 재사용), 검색·선택 이벤트를 `Intent`으로 발행 |
| `SearchScreen.Model.swift` | 비즈니스 로직. `search(by:) async -> Result<[User], Status>` — 취소는 `.idle`로 변환 |
| `SearchScreen.ViewModel.swift` | `@Published private(set)` 상태(rows/isLoading/얼럿/route) + `reduce(by:)` + Task 취소 디바운스 |
| `SearchScreen.ViewController.swift` | 생명주기·입력·출력 바인딩. `$프로퍼티` 구독으로 렌더/얼럿/push |

## 바인딩 방식

- 입력: Context가 `UISearchResultsUpdating`·`didSelectRowAt`을 `Intent`(`.input` / `.select`)으로
  발행 → VC가 `viewModel.reduce(by:)`로 중계. 출력: VC가 `$rows` / `$isLoading` /
  `$presentedAlertString` / `$route`를 구독해 스냅샷 적용·스피너·얼럿·push를 수행한다.
  `$프로퍼티`는 구독 시점에 현재 값을 즉시 방출하므로 초기 렌더링도 같은 경로다.
- 생명주기도 스트림: CommonUIKit의 `PublishedViewLifeCycleViewController`가
  `loadView`/`viewDidLoad`를 퍼블리셔로 노출하고, VC는 그 구독 안에서 view 교체와
  `UISearchController` 부착을 수행한다. (`loadView` 이벤트는 동기 전달이 전제 —
  중간에 `receive(on:)`을 끼우면 기본 빈 뷰가 먼저 설치된다.)
- 내비게이션도 상태: `.select` → `@Published var route: Screen?` → VC가 구독해 push.
- 디바운스 = SwiftUI+Published와 동일한 Task 취소 구현. 빈 입력은 rows `nil` 리셋 +
  진행 중 요청 취소, 취소는 `CancellationError → .idle`로 변환되어 얼럿으로 새지 않는다.
- 빈 화면 상태는 `UIContentUnavailableConfiguration`(`empty()` / `search()`)으로 그린다 —
  SwiftUI 변형의 `ContentUnavailableView`와 같은 계열이라 화면이 일치한다.

## UIKit+Transform과의 차이

- **UIKit+Published**: ViewModel이 상태를 **소유**하고 `@Published`로 노출 → VC가 구독.
  입력은 `reduce(by:)` 메서드 호출, 시간축 로직은 Task 취소.
- **UIKit+Transform**: 입력 스트림을 받아 출력 스트림으로 **변환**(transform).
  시간축 로직(디바운스 등)이 전부 Combine 연산자 파이프라인 안에 있다.

## 장점

- 이해할 개념이 적다. `@Published` + `sink`만 알면 된다.
- 상태가 프로퍼티로 존재하므로 아무 때나 현재 상태를 읽을 수 있고,
  테스트에서 `viewModel.rows` / `viewModel.route` 단언이 간단하다.
- SwiftUI+Published와 ViewModel 형태가 같아, View 레이어 차이만 순수하게 비교된다.

## 한계

- 출력이 늘어날수록 `@Published` 프로퍼티가 늘어나며 상태 간 정합성 관리가 번거로워진다.
- 구독(cancellableSet) 수명 관리를 수동으로 해야 한다.
- 디바운스 경과를 기다려야 하는 `settle()` 스타일 테스트가 필요하다.
