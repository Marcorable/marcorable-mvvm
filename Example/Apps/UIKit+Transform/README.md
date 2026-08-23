# UIKit+Transform — Combine Input/Output MVVM

실무에서 널리 쓰이는 transform 패턴. View의 이벤트를 Input 스트림으로 받아 Output(화면 상태) 스트림으로 변환한다.

## 바인딩 방식

- `ViewModel.transform(Input) -> Output`이 유일한 진입점. Input은 생명주기(`viewLife`)와
  사용자 이벤트(`action`) 스트림, Output은 `isLoading` / `rows` / `status` 퍼블리셔다.
- 디바운스·중복 제거·요청 갈아타기(`switchToLatest`)가 전부 선언형 파이프라인 안에 있다.
- rows는 `CurrentValueSubject`에 `multicast`로 흘려, 행 선택 시 이벤트 시점의 최신 rows를
  `.value` 스냅샷으로 읽는다 (`withLatestFrom` 등가 — `combineLatest`로 조합하면
  rows 갱신 때마다 route가 재방출되는 유령 push가 생긴다).
- `.setup`(초기 구성) / `.alert`(실패) / `.route`(내비게이션)는 `status` 스트림 하나로
  단방향 방출되고, VC는 switch로 렌더만 한다.

## 장점

- 디바운스, 중복 제거, 이전 요청 폐기 같은 시간축 로직이 연산자 조합으로 끝난다.
- Input/Output이 명시적 계약이라 ViewModel의 API가 자기문서화된다.
- 테스트에서 Input에 값을 흘리고 Output을 수집하면 되므로 시나리오 테스트가 자연스럽다.

## 한계

- Combine 학습 곡선이 있고, async/await 브릿징을 인라인 `Future` + `Task`로 직접 해야 한다.
- `Future` 기반 브릿징은 구독 취소가 내부 Task(네트워크)까지 전파되지 않는다 —
  `switchToLatest`는 결과만 폐기한다. (Task 취소 디바운스를 쓰는 다른 세 변형과의 차이)
- 스트림이 복잡해지면 디버깅 난도가 올라간다. `share()` / `multicast` 위치를 놓치면
  구독마다 파이프라인이 복제되어 요청이 중복 실행된다.
