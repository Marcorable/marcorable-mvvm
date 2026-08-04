
import Combine
import Foundation

import SharedKit

@MainActor
final class SearchViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded([User])
        case failed(String)
    }

    struct Input {
        let query: AnyPublisher<String, Never>
    }

    struct Output {
        let state: AnyPublisher<State, Never>
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

extension SearchViewModel {

    struct Dependency {
        let repository: UserRepository
    }

}

extension SearchViewModel {

    func transform(_ input: Input) -> Output {
        let repository = dependency.repository

        let state = input.query
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { query -> AnyPublisher<State, Never> in
                guard !query.isEmpty else {
                    return Just(.idle).eraseToAnyPublisher()
                }
                return Publishers.fromAsync { try await repository.searchUsers(by: query) }
                    .map(State.loaded)
                    .catch { Just(State.failed($0.localizedDescription)) }
                    .prepend(.loading)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return Output(state: state)
    }

    func login(for user: User) -> String {
        user.login
    }

}
