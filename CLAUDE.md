# MarcorableMVVM

같은 앱(GitHub 유저 검색 → 상세)을 여러 MVVM 변형으로 구현해 비교하는 예제 워크스페이스.

## 프로젝트 관리 (Tuist)

- 프로젝트 파일 재생성은 반드시 `Scripts/generate.sh` 사용 (`tuist generate` 단독 실행 금지 —
  가상 그룹('Project' 래퍼, 'Packages', 'Products') 정리 후처리가 빠져 네비게이터가 지저분해진다).
- 모든 타깃은 그룹이 아닌 **폴더(synchronized folder, `buildableFolders`)** 로 관리한다.
  pbxproj에 파일 참조를 직접 추가하지 않는다. 파일 추가/삭제는 디스크에서만 하면 된다.
- Info.plist 파일을 만들지 않는다. `GENERATE_INFOPLIST_FILE = YES` + `INFOPLIST_KEY_*` 빌드 설정으로
  생성하고, UIKit 앱의 씬 델리게이트는 AppDelegate에서 `configuration.delegateClass`로 코드 지정한다.
- Tuist 버전은 mise로 고정 (`~/Documents/.mise.toml`).

## 아키텍처 규칙

- Domain(모델·`UserRepository` 프로토콜)과 Data(GitHub API·Mock) 레이어는 `Packages/SharedKit`에만 둔다.
  예제 프로젝트에는 View / ViewModel / (필요시 Coordinator)만 남긴다.
- 모든 예제는 동일한 앱, 동일한 `Sources/Scenes/Search`, `Sources/Scenes/Detail` 구조를 유지한다 —
  프로젝트 간 차이가 순수하게 바인딩 방식의 차이만 되도록.
- 화면 상태는 `enum State { idle, loading, loaded, failed }` 하나로 모델링한다.
  (`isLoading` 플래그 + 데이터 배열 분리 금지)
- 새 예제(변형)를 추가할 때: `Examples/<이름>/` + `Project.swift` + 예제 README(장단점 정리) +
  ViewModel 유닛 테스트(MockUserRepository 사용)를 갖추고, `Docs/COMPARISON.md` 표에 추가한다.

## 코드 스타일

- `switch` 안의 `case`는 한 단계 들여쓴다 (Xcode "Indent case statements" 스타일):
  ```swift
  switch state {
      case .idle:
          ...
      case .loading:
          ...
  }
  ```
- 주석과 사용자 노출 문자열(에러 메시지, 빈 상태 문구 등)은 한국어로 쓴다.

## 검증

- 변경 후에는 4개 스킴(UIKit+Published, UIKit+Transform, SwiftUI+Published, SwiftUI+Observable) 전부 테스트
  (스킴명에 '+'가 있으니 따옴표로 감싼다. 모듈명은 '+' 제거형: UIKitPublished 등): `xcodebuild -workspace MarcorableMVVM.xcworkspace -scheme <스킴> -destination 'platform=iOS Simulator,name=iPhone 17' test`
- SharedKit 단독 검증은 `Packages/SharedKit`에서 `swift test`.
- Common 패키지는 iOS 전용(UIKit 포함)이라 `swift test`가 안 된다 — `Packages/Common`에서
  `xcodebuild -scheme Common-Package -destination 'platform=iOS Simulator,name=iPhone 17' test`.
- 시뮬레이터가 앱 실행을 거부하는 간헐적 플레이크("failed preflight checks" / Busy)가 있다 —
  코드 문제가 아니므로 해당 스킴만 재시도한다.
