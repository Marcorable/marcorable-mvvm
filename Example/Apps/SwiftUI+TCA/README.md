# SwiftUI + TCA

The Composable Architecture(TCA)를 사용한 단방향 아키텍처 변형.

## 구조

| 파일 | 역할 |
|---|---|
| `SearchScreen.swift` | 네임스페이스 + Status enum + debounce 상수 |
| `SearchScreen.Model.swift` | 비즈니스 로직 (다른 변형과 동일) |
| `SearchScreen.Feature.swift` | `@Reducer` — State/Action/Effect (Model+ViewModel 역할) |
| `SearchScreen.Context.swift` | SwiftUI View (`StoreOf<Feature>` 구독) |

## 장점

- **단일 진실 공급원**: State가 유일한 상태이고, Action을 통해서만 변경된다.
  다른 변형에서 ViewModel의 여러 `@Published`/`@Observable` 프로퍼티가 각자 바뀌는 것과 대조적.
- **테스트가 결정적**: `TestStore` + `TestClock`으로 디바운스·비동기 흐름을 벽시계 없이 재현한다.
  `settle()` 대기나 `expectation`이 필요 없다.
- **Effect 취소가 명시적**: `.cancellable(id:cancelInFlight:)`로 디바운스 취소를 선언한다.
  Task 취소 계열보다 의도가 드러난다.
- **상태 변경 추적**: TestStore가 매 Action마다 정확한 State diff를 강제하므로
  의도치 않은 상태 변경을 컴파일 단계에서 잡는다.

## 단점

- **의존성 무게**: TCA 하나에 swift-dependencies, swift-case-paths, swift-perception 등
  여러 트랜시티브 의존성이 딸려온다. 빌드 시간과 바이너리 크기에 영향.
- **학습 곡선**: Reducer, Effect, Store, TestStore, CasePathable 등 TCA 고유 개념이 많다.
  팀 전체가 숙지해야 유지보수 가능.
- **보일러플레이트**: Action case마다 `return .none`을 써야 하고,
  TestStore 테스트는 모든 중간 Action을 순서대로 receive해야 한다.
- **프레임워크 결합**: 앱 코드가 ComposableArchitecture에 강하게 묶인다.
  다른 변형은 표준 라이브러리(Combine, Observation)만 사용.

## 다른 변형과 비교

| 관점 | MVVM 변형들 | TCA |
|---|---|---|
| 상태 관리 | 프로퍼티 직접 변경 | Action → Reduce → State |
| 사이드 이펙트 | Task / Combine 직접 관리 | Effect 타입으로 선언 |
| 디바운스 | Task.sleep / Combine 연산자 | TestClock + cancellable |
| 테스트 | XCTest + settle/expectation | TestStore (결정적) |
| 의존성 | 없음 (표준 라이브러리) | ComposableArchitecture + 트랜시티브 |
