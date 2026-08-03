import Combine
import Foundation

extension Publishers {

    /// async 함수를 Combine 파이프라인에서 사용할 수 있게 감싼다.
    /// 주의: Future 기반이라 구독 취소가 내부 Task까지 전파되지는 않는다.
    /// (switchToLatest로 갈아탈 때 이전 요청의 결과가 버려지는 것으로 충분한 예제 수준 구현)
    static func fromAsync<Output>(
        _ operation: @escaping @Sendable () async throws -> Output
    ) -> AnyPublisher<Output, Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        promise(.success(try await operation()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

}
