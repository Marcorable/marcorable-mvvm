# MVVM 변형 비교

네 예제는 **같은 앱**(GitHub 유저 검색 → 상세)이다. Domain/Data(SharedKit)와
공용 UI(CommonScene — 행 컴포넌트·Detail 화면·내비게이션)를 공유하므로,
차이는 오직 **View–ViewModel 바인딩 방식**이다.

## 한눈에 보기

| 예제 | UI | 바인딩 | 디바운스 | 내비게이션 주체 |
|---|---|---|---|---|
| UIKit+Published | UIKit | `@Published` 상태를 VC가 직접 구독, 입력은 `Action` | ViewModel (Task 취소) | VC (`$route` 구독) |
| UIKit+Transform | UIKit | Combine Input/Output transform | ViewModel (연산자) | VC (`status` 스트림) |
| SwiftUI+Published | SwiftUI | `ObservableObject` + `@Published`, 입력은 `Action` | ViewModel (Task 취소) | `NavigationStack` (View) |
| SwiftUI+Observable | SwiftUI | `@Observable` (iOS 17+) | View (`.task(id:)`) | `NavigationStack` (View) |

## 관전 포인트

1. **파일 대 파일 비교** — 네 변형 모두 `SearchScreen.*` 구조를 쓴다.
   `Model`은 네 곳이 사실상 동일하고, 차이는 전부 `ViewModel`과 View 레이어에 있다.
2. **디바운스 구현** — Transform만 Combine 연산자이고, 나머지 셋은 전부
   **Task 취소(sleep + 취소 확인)**다. 그 안에서도 소유자가 갈린다:
   Published 둘은 ViewModel이, Observable은 View(`.task(id:)`)가 쥔다.
3. **취소 전파** — Task 취소 계열은 구조적 동시성으로 네트워크 요청까지 중단되고,
   Transform의 `Future` 브릿지는 결과만 폐기한다(`switchToLatest`).
   어느 쪽이든 취소가 얼럿으로 새지 않도록 Model이 `CancellationError → .idle`로 변환한다.
4. **테스트 난이도** — Observable은 대기 없이 `await search()` 한 줄.
   Published 둘은 디바운스 경과를 기다리는 `settle()` 벽시계 대기.
   Transform은 Input에 값을 흘리고 Output을 expectation으로 수집한다.
5. **공통 정책** — 네 변형이 같은 화면 정책을 공유하고 `FailurePolicyTests`가
   같은 이름의 시나리오로 단언한다: 실패 시 이전 rows 유지 + alert,
   빈 쿼리는 rows `nil` 리셋, 에러는 스트림 종료 신호가 아닌 **값**(`Status`)으로 다룬다.

## 어떤 것을 쓸까 (사견)

- iOS 17+ 새 프로젝트: **SwiftUI+Observable**.
- UIKit 코드베이스: 팀이 Rx/Combine에 익숙하면 **UIKit+Transform**, 아니면 **UIKit+Published**.
- 화면 흐름이 복잡하거나 딥링크가 중요하면 **Coordinator** 분리를 고려. (별도 패키지 예정)
