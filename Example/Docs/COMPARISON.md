# MVVM 변형 비교

네 예제는 **같은 앱**(GitHub 유저 검색 → 상세)이다. Domain/Data(SharedKit)와
공용 UI(CommonScene)를 공유하므로, 차이는 오직 **View–ViewModel 바인딩 방식**이다.

## 한눈에 보기

| 예제 | UI | 바인딩 | 디바운스 위치 | 내비게이션 주체 |
|---|---|---|---|---|
| UIKit+Published | UIKit | `@Published` 상태를 VC가 직접 구독 | ViewModel (Task 취소) | ViewController |
| UIKit+Transform | UIKit | Combine Input/Output transform | ViewModel (연산자) | ViewController |
| SwiftUI+Published | SwiftUI | `ObservableObject` + `@Published`, `Result` 값 스트림 분리 | ViewModel (`$input` 구독) | `NavigationStack` (View) |
| SwiftUI+Observable | SwiftUI | `@Observable` (iOS 17+) | View (`.task(id:)`) | `NavigationStack` (View) |

## 관전 포인트

1. **파일 대 파일 비교** — 두 SwiftUI 변형은 `SearchScreen.*` 네 파일이 1:1 대응된다.
   `Model`은 사실상 동일하고, 차이는 전부 `ViewModel`과 `Context`에 있다.
2. **시간축 로직의 소유자** — Published는 ViewModel(`$input` 구독 파이프라인),
   Observable은 View(`.task(id: trimmedInput)` = sleep + 취소). 이 한 가지 선택이
   아래 두 포인트를 결정한다.
3. **테스트 난이도** — Observable은 대기 없이 `await search()` 한 줄로 끝나고,
   Published는 디바운스 경과를 기다리는 `settle()`이 필요하다.
   UIKit 둘은 sink/expectation으로 상태를 수집한다.
4. **상태 모델링** — UIKit 둘은 단일 `enum State`(불가능한 상태 조합을 원천 차단),
   SwiftUI 둘은 `rows` / `isLoading` / 얼럿 분리(실패 시 이전 rows 유지 UX).
   같은 정책을 양쪽 `FailurePolicyTests`가 같은 이름의 시나리오로 단언한다.
5. **공통 원칙** — 에러는 스트림 종료 신호가 아닌 **값**으로 다룬다.
   실패가 화면 상태로 흘러야 다음 검색이 계속 동작한다.

## 어떤 것을 쓸까 (사견)

- iOS 17+ 새 프로젝트: **SwiftUI+Observable**.
- UIKit 코드베이스: 팀이 Rx/Combine에 익숙하면 **UIKit+Transform**, 아니면 **UIKit+Published**.
- 화면 흐름이 복잡하거나 딥링크가 중요하면 **Coordinator** 분리를 고려. (별도 패키지 예정)
