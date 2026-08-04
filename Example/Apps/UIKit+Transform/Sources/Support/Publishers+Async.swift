
import Combine
import Foundation

extension Publishers {

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
