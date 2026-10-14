# marcorable-mvvm

레포 루트는 `NavigationCoordinator` 라이브러리를 배포하는 **marcorable-mvvm SPM 패키지**다
(`Package.swift` + `Sources/NavigationCoordinator/`).
예제 워크스페이스 일체는 `Example/` 아래에 있다 — 앱은 `Example/Apps/`,
보조 패키지(SharedKit·Common)는 `Example/Packages/`, Tuist 매니페스트와 스크립트도 `Example/`.

## 프로젝트 관리 (Tuist)

- 프로젝트 파일 재생성은 반드시 `Example/`에서 `Scripts/generate.sh` 사용 (`tuist generate` 단독 실행 금지 —
  가상 그룹('Project' 래퍼, 'Packages', 'Products') 정리 후처리가 빠져 네비게이터가 지저분해진다).
- 모든 타깃은 그룹이 아닌 **폴더(synchronized folder, `buildableFolders`)** 로 관리한다.
  pbxproj에 파일 참조를 직접 추가하지 않는다. 파일 추가/삭제는 디스크에서만 하면 된다.
- Info.plist 파일을 만들지 않는다. `GENERATE_INFOPLIST_FILE = YES` + `INFOPLIST_KEY_*` 빌드 설정으로
  생성하고, UIKit 앱의 씬 델리게이트는 AppDelegate에서 `configuration.delegateClass`로 코드 지정한다.
- Tuist 버전은 mise로 고정 (`~/Documents/.mise.toml`).

## 아키텍처 규칙

- Domain(모델·`UserRepository` 프로토콜)과 Data(GitHub API·Mock) 레이어는 `Example/Packages/SharedKit`에만 둔다.
  예제 프로젝트에는 View / ViewModel / (필요시 Coordinator)만 남긴다.
- 공용 화면(Detail)과 백엔드별 코디네이터는 `Example/Packages/Common`에 둔다
  (제품: CommonScene / CommonUIKit). 예제 앱에는 Search 씬과 조립부만 남긴다 —
  프로젝트 간 차이가 순수하게 바인딩 방식의 차이만 되도록.
- 화면 상태는 `rows`(Optional) / `isLoading` / 얼럿 문자열로 분리하고, 실패·취소는
  `Status` enum(`.idle` / `.alert`)으로 값 변환해 흘린다. 공통 정책: 실패 시 이전 rows 유지,
  취소는 얼럿 없이 무시(`CancellationError` → `.idle`), 빈 쿼리는 rows `nil` 리셋 —
  각 변형의 `FailurePolicyTests`가 같은 이름의 시나리오로 이 정책을 단언한다.
- 새 예제(변형)를 추가할 때: `Example/Apps/<이름>/` + `Project.swift` + 예제 README(장단점 정리) +
  ViewModel 유닛 테스트(MockUserRepository 사용)를 갖추고, `Example/Docs/COMPARISON.md` 표에 추가한다.

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
- 최종 코드에는 주석을 남기지 않는다 (`// MARK:`, `///` 문서 주석 포함).
  설명이 필요하면 주석 대신 답변으로 전달한다. 예외는 `Package.swift`의 `// swift-tools-version:` 지시어뿐.
- 사용자 노출 문자열(에러 메시지, 빈 상태 문구 등)은 한국어로 쓴다.

## 검증

- 루트 패키지는 `swift build`로 검증한다 (아직 테스트 타깃 없음 — 추가 시 루트 `Tests/`).
- 예제는 `Example/`에서 4개 스킴(UIKit+Published, UIKit+Transform, SwiftUI+Published, SwiftUI+Observable) 전부 테스트
  (스킴명에 '+'가 있으니 따옴표로 감싼다. 모듈명은 '+' 제거형: UIKitPublished 등): `xcodebuild -workspace Example.xcworkspace -scheme <스킴> -destination 'platform=iOS Simulator,name=iPhone 17' test`
- SharedKit 단독 검증은 `Example/Packages/SharedKit`에서 `swift test`.
- Common 패키지는 iOS 전용(UIKit 포함)이라 `swift test`가 안 된다 — `Example/Packages/Common`에서
  `xcodebuild -scheme Common-Package -destination 'platform=iOS Simulator,name=iPhone 17' test`.
- 시뮬레이터가 앱 실행을 거부하는 간헐적 플레이크("failed preflight checks" / Busy)가 있다 —
  코드 문제가 아니므로 해당 스킴만 재시도한다.
- 패키지를 옮긴 뒤 `precompiled file ... module cache path` 에러가 나면 stale `.build` 때문이다 —
  해당 패키지의 `.build`를 지우고 재시도한다.
