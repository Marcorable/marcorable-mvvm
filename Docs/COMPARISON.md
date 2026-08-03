# MVVM 변형 비교

네 예제는 전부 **같은 앱**(GitHub 유저 검색 → 상세)이고, Domain/Data 레이어(SharedKit)를 공유한다.
따라서 프로젝트 간 차이는 순수하게 "View–ViewModel 바인딩 방식"의 차이다.

## 한눈에 보기

| 예제 | UI | 바인딩 | 디바운스 위치 | 내비게이션 주체 |
|---|---|---|---|---|
| UIKit+Published | UIKit | `@Published` 상태를 VC가 직접 구독 | ViewModel (Task 취소) | ViewController |
| UIKit+Transform | UIKit | Combine Input/Output transform | ViewModel (연산자) | ViewController |
| SwiftUI+Published | SwiftUI | `ObservableObject` + `@Published` | ViewModel (`$query` 구독) | `NavigationStack` (View) |
| SwiftUI+Observable | SwiftUI | `@Observable` (iOS 17+) | View (`.task(id:)`) | `NavigationStack` (View) |

## 관전 포인트

### 1. 같은 파일끼리 비교하기

- `SearchViewModel.swift`를 네 프로젝트에서 나란히 열어보면 각 방식의 본질적 차이가 보인다.
  상태 enum은 전부 동일하고, "상태를 어떻게 밖으로 내보내는가"만 다르다.

### 2. 테스트 코드가 말해주는 것

각 예제의 `Tests/`를 비교하면 "테스트하기 쉬운 정도"가 드러난다.

- UIKit+Published: `$state`를 sink로 수집 → 직관적이지만 `searchTask`를 기다리는 요령이 필요.
- UIKit+Transform: Input에 값을 흘리고 Output을 수집 → 시나리오 서술이 자연스럽지만 expectation 보일러플레이트.
- SwiftUI+Published: 디바운스가 main queue를 경유해서 폴링성 대기가 필요 → 가장 번거로움.
- SwiftUI+Observable: `await viewModel.search()` 한 줄 → 가장 단순.

### 3. 상태 모델링은 공통

네 변형 모두 `enum State { idle, loading, loaded, failed }`로 화면 상태를 모델링했다.
바인딩 기술과 무관하게, **화면 상태를 enum 하나로 모으는 것**이 MVVM 품질의 절반이다.
(불변식: `users` 배열과 `isLoading` 플래그를 따로 두면 불가능한 조합이 생긴다.)

## 어떤 것을 쓸까 (사견)

- 새 프로젝트 + iOS 17 이상: **SwiftUI+Observable** 방식이 기본값.
- UIKit 유지보수 코드베이스: 팀이 Rx/Combine에 익숙하면 **UIKit+Transform**, 아니면 **UIKit+Published**.
- 화면 흐름이 5개 이상으로 복잡하거나 딥링크가 중요하면 어느 조합이든 **Coordinator**(내비게이션 책임 분리)를 얹는 것을 고려.
  (Coordinator 추상화는 별도 패키지로 분리할 예정)
