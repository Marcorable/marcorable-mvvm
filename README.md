# marcorable-mvvm

MVVM 디자인패턴을 다양하게 고민해본다.

화면 전환을 추상화한 `NavigationCoordinator`를 제공하는 Swift 패키지이고,
같은 앱을 네 가지 MVVM 변형으로 구현한 예제 워크스페이스를 `Example/`에 함께 담았다.

## 설치

```swift
dependencies: [
    .package(url: "https://github.com/Marcorable/marcorable-mvvm.git", from: "0.1.0")
]
```

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "NavigationCoordinator", package: "marcorable-mvvm")
    ]
)
```

## NavigationCoordinator

화면 스택 조작의 공통 제약이다. Screen이 무엇인지(라우트 enum, `UIViewController` 등)와
백엔드가 무엇인지(`UINavigationController`, `NavigationStack`의 path)는 구현체가 결정한다.

```swift
@MainActor
public protocol NavigationCoordinator: AnyObject {
    associatedtype Screen: Hashable

    func action(by action: NavigationAction<Screen>)
}

public enum NavigationAction<Screen: Hashable>: Hashable {
    case push(contentsOf: [Screen])
    case pop(count: Int = 1)
    case popToRoot
}
```

구현체는 `action(by:)` 하나만 구현하면 되고, UIKit이든 SwiftUI든 같은 어휘로 화면을 전환한다.
실제 구현은 `Example/Packages/Common`의 `AppCoordinator`(UINavigationController)와
`MainNavigationStack`(NavigationStack path)을 참고.

## 구조

```
marcorable-mvvm/
├── Package.swift             # SPM 패키지 (product: NavigationCoordinator)
├── Sources/NavigationCoordinator/
└── Example/                  # 예제 워크스페이스 (배포물에 포함되지 않음)
    ├── Example.xcworkspace
    ├── Apps/
    │   ├── UIKit+Published       # @Published 상태를 VC가 직접 구독 (기본형)
    │   ├── UIKit+Transform       # Combine Input/Output transform 패턴
    │   ├── SwiftUI+Published     # ObservableObject + @Published
    │   └── SwiftUI+Observable    # @Observable (iOS 17+), 순수 async/await
    ├── Packages/
    │   ├── SharedKit             # 공유 Domain(모델·프로토콜) + Data(GitHub API·Mock)
    │   └── Common                # 공용 화면(Detail) + 백엔드별 코디네이터
    └── Docs/COMPARISON.md        # 변형 간 비교와 관전 포인트
```

## 예제 열기

프로젝트 파일(`*.xcodeproj`)은 [Tuist](https://tuist.io)로 생성하며 저장소에 포함되지 않는다.
clone 후 최초 1회, 그리고 프로젝트 구조를 바꿨을 때 `Example/`에서:

```bash
Scripts/generate.sh
```

생성된 `Example/Example.xcworkspace`를 Xcode로 열면 된다. 각 예제는 독립된 앱 스킴으로 실행/테스트한다.

(`tuist generate` 후 Tuist가 만드는 표시용 가상 그룹('Project' 래퍼, 'Packages', 'Products')을
정리하는 후처리까지 수행해, 네비게이터에 Sources/Tests 폴더만 남긴다.
모든 소스는 그룹이 아닌 폴더(synchronized folder)로 관리되므로,
Xcode에서 파일을 추가/삭제해도 프로젝트 재생성이 필요 없다.)

모든 예제는 동일한 화면 구성이다:

1. **검색**: GitHub 유저 검색 (디바운스, 로딩/빈 결과/에러 상태)
2. **상세**: 선택한 유저의 프로필 (이름, 소개, 팔로워/저장소 수)

GitHub API를 인증 없이 사용하므로 검색은 분당 10회 rate limit이 있다.
테스트와 프리뷰는 `MockUserRepository`를 사용한다.
각 예제 폴더의 README에 해당 방식의 장단점을 정리해두었다.
