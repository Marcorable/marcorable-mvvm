# MVVM 변형 비교

네 예제는 전부 **같은 앱**(GitHub 유저 검색 → 상세)이고, Domain/Data 레이어(SharedKit)를 공유한다.
따라서 프로젝트 간 차이는 순수하게 "View–ViewModel 바인딩 방식"의 차이다.

## 한눈에 보기

| 예제 | UI | 바인딩 | 디바운스 위치 | 내비게이션 주체 |
|---|---|---|---|---|
| UIKit+Published | UIKit | `@Published` 상태를 VC가 직접 구독 | ViewModel (Task 취소) | ViewController |
| UIKit+Transform | UIKit | Combine Input/Output transform | ViewModel (연산자) | ViewController |
| SwiftUI+Published | SwiftUI | `ObservableObject` + `@Published`, `Result` 값 스트림 분리 | ViewModel (`$input` 구독) | `NavigationStack` (View) |
| SwiftUI+Observable | SwiftUI | `@Observable` (iOS 17+) | View (`.task(id:)`) | `NavigationStack` (View) |

## 관전 포인트

### 1. 같은 파일끼리 비교하기

- 각 프로젝트의 ViewModel을 나란히 열어보면 각 방식의 본질적 차이가 보인다
  (SwiftUI+Published만 `SearchScreen.ViewModel.swift`, 나머지는 `SearchViewModel.swift`).
  같은 검색 흐름을 두고 "상태를 어떻게 밖으로 내보내는가"만 다르다.

### 2. 테스트 코드가 말해주는 것

각 예제의 `Tests/`를 비교하면 "테스트하기 쉬운 정도"가 드러난다.

- UIKit+Published: `$state`를 sink로 수집 → 직관적이지만 `searchTask`를 기다리는 요령이 필요.
- UIKit+Transform: Input에 값을 흘리고 Output을 수집 → 시나리오 서술이 자연스럽지만 expectation 보일러플레이트.
- SwiftUI+Published: Model은 순수 async라 `await` 한 줄로 끝나지만,
  ViewModel은 디바운스가 main queue를 경유해서 폴링성 대기가 필요 → 가장 번거로움.
- SwiftUI+Observable: `await viewModel.search()` 한 줄 → 가장 단순.

### 3. 상태 모델링 — 단일 enum vs 분리 스트림

세 변형(UIKit 둘, SwiftUI+Observable)은 `enum State { idle, loading, loaded, failed }` 하나로
화면 상태를 모델링했다. 상태를 enum 하나로 모으면 `users` 배열과 `isLoading` 플래그가
어긋나는 불가능한 조합이 원천 차단된다.

SwiftUI+Published는 의도적으로 다른 접근을 택했다: 검색 결과를 `Result` 값 스트림으로 흘리고
`successes()` / `failures()`로 갈래를 나눠 `rows` / `isLoading` / `presentedAlertString`에
따로 바인딩한다. 실패 시 이전 결과를 유지한 채 alert만 띄우는 UX가 자연스럽게 나오는 대신,
상태 프로퍼티 간 정합은 파이프라인 설계가 책임져야 한다. 두 접근의 트레이드오프를
비교해보는 것이 이 변형의 관전 포인트다.

한 가지는 네 변형이 공통이다: **에러를 스트림 종료 신호가 아닌 값으로 다룬다.**
실패가 화면 상태(`failed` case든 alert든)로 흘러야 다음 검색이 계속 동작한다.

## 어떤 것을 쓸까 (사견)

- 새 프로젝트 + iOS 17 이상: **SwiftUI+Observable** 방식이 기본값.
- UIKit 유지보수 코드베이스: 팀이 Rx/Combine에 익숙하면 **UIKit+Transform**, 아니면 **UIKit+Published**.
- 화면 흐름이 5개 이상으로 복잡하거나 딥링크가 중요하면 어느 조합이든 **Coordinator**(내비게이션 책임 분리)를 얹는 것을 고려.
  (Coordinator 추상화는 별도 패키지로 분리할 예정)
