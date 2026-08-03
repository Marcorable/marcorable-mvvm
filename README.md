# MarcorableMVVM

MVVM 디자인패턴을 다양하게 고민해본다.

같은 앱(GitHub 유저 검색 → 상세)을 다섯 가지 MVVM 변형으로 구현하고, 한 워크스페이스에서 나란히 비교하는 저장소.
Domain/Data 레이어는 `SharedKit` 패키지로 공유하므로, 프로젝트 간 차이는 순수하게 바인딩 방식의 차이다.

## 구조

```
MarcorableMVVM.xcworkspace
├── Packages/SharedKit        # 공유 Domain(모델·프로토콜) + Data(GitHub API·Mock)
├── Examples/
│   ├── UIKitClosure          # 클로저 바인딩 (기본형, 의존성 없음)
│   ├── UIKitCombine          # Combine Input/Output transform 패턴
│   ├── SwiftUIClassic        # ObservableObject + @Published
│   ├── SwiftUIObservable     # @Observable (iOS 17+), 순수 async/await
│   └── CoordinatorMVVM       # MVVM-C: 내비게이션을 Coordinator로 분리
└── Docs/COMPARISON.md        # 변형 간 비교와 관전 포인트
```

각 예제 폴더의 README에 해당 방식의 장단점을 정리해두었다.

## 열기

`MarcorableMVVM.xcworkspace`를 Xcode로 열면 된다. 각 예제는 독립된 앱 스킴으로 실행/테스트한다.

프로젝트 파일은 [Tuist](https://tuist.io)로 생성한다. 구조를 바꿨다면:

```bash
Scripts/generate.sh
```

(`tuist generate` 후 Tuist가 만드는 가상 'Project' 래퍼 그룹을 평탄화하는 후처리까지 수행한다.
모든 소스는 그룹이 아닌 폴더(synchronized folder)로 관리되므로,
Xcode에서 파일을 추가/삭제해도 프로젝트 재생성이 필요 없다.)

## 예제 앱

모든 예제는 동일한 화면 구성이다:

1. **검색**: GitHub 유저 검색 (디바운스, 로딩/빈 결과/에러 상태)
2. **상세**: 선택한 유저의 프로필 (이름, 소개, 팔로워/저장소 수)

GitHub API를 인증 없이 사용하므로 검색은 분당 10회 rate limit이 있다.
테스트와 프리뷰는 `MockUserRepository`를 사용한다.
