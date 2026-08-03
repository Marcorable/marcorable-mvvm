# UIKitCombine — Combine Input/Output MVVM

실무에서 널리 쓰이는 transform 패턴. View의 이벤트를 Input 스트림으로 받아 Output(화면 상태) 스트림으로 변환한다.

## 바인딩 방식

- `SearchViewModel.transform(Input) -> Output`이 유일한 진입점. 디바운스·중복 제거·요청 갈아타기(switchToLatest)가 전부 선언형 파이프라인 안에 있다.
- ViewController는 `PassthroughSubject`로 검색어를 흘려보내고, `output.state`를 구독해 `render(_:)`만 호출한다.
- 상세 화면은 입력이 단순해 `@Published` 상태 노출 방식을 혼용했다 — 화면 복잡도에 따라 패턴을 섞을 수 있음을 보여준다.

## 장점

- 디바운스, 중복 제거, 이전 요청 폐기 같은 시간축 로직이 연산자 조합으로 끝난다.
- Input/Output이 명시적 계약이라 ViewModel의 API가 자기문서화된다.
- 테스트에서 Input에 값을 흘리고 Output을 수집하면 되므로 시나리오 테스트가 자연스럽다.

## 한계

- Combine 학습 곡선이 있고, async/await와 브릿징(`Publishers.fromAsync`)이 필요하다.
- Future 기반 브릿징은 구독 취소가 내부 Task까지 전파되지 않는다(예제에서는 switchToLatest로 결과만 폐기).
- 스트림이 복잡해지면 디버깅 난도가 올라간다.
