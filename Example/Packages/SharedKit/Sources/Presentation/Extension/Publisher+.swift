
import Combine

extension Publisher where Failure == Never {

    public func successes<Success, Failure: Error>() -> AnyPublisher<Success, Never>
    where Output == Result<Success, Failure> {
        self.compactMap({ try? $0.get() })
            .eraseToAnyPublisher()
    }

    public func failures<Success, Failure: Error>() -> AnyPublisher<Failure, Never>
    where Output == Result<Success, Failure> {
        self.compactMap({ result -> Failure? in
            guard case .failure(let error) = result else { return nil }
            return error
        })
        .eraseToAnyPublisher()
    }

}
