# Changelog

## 0.2.0 - 2026-10-20

Navigation API를 명령형 `Navigator` 중심 구조로 개편했습니다.

- `Navigator<Screen>`과 navigation action publisher 추가
- `push`, `pop`, `popToRoot`, `restack` 명령형 API 제공
- UIKit과 SwiftUI 예제에서 동일한 `Navigator`를 사용하도록 통합
- SwiftUI environment를 통한 화면 계층 내 `Navigator` 공유
- 기존 `NavigationAction`, `AppCoordinator`, `mainStack` environment API 제거

## 0.1.0 - 2026-10-20

첫 공개 배포입니다.

- `NavigationCoordinator` Swift Package 라이브러리 제공
- UIKit과 SwiftUI에서 공통으로 사용할 수 있는 화면 전환 액션 정의
- `@Published`, Combine transform, `ObservableObject`, `@Observable` 기반 MVVM 예제 제공
- 공통 검색·상세 화면과 GitHub 사용자 저장소 예제 제공
