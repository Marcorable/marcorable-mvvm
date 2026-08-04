
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

    @Published private(set) var state: State = .idle

    private let dependency: Dependency
    private let debounce: Duration
    private(set) var searchTask: Task<Void, Never>?

    init(
        dependency: Dependency,
        debounce: Duration = .milliseconds(300)
    ) {
        self.dependency = dependency
        self.debounce = debounce
    }
}

extension SearchViewModel {

    struct Dependency {
        let repository: UserRepository
    }

}

extension SearchViewModel {

    func search(query: String) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            state = .idle
            return
        }

        let repository = dependency.repository

        searchTask = Task { [debounce] in
            do {
                try await Task.sleep(for: debounce)
                state = .loading
                let users = try await repository.searchUsers(by: trimmed)
                guard !Task.isCancelled else { return }
                state = .loaded(users)
            } catch is CancellationError {
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error.localizedDescription)
            }
        }
    }

}
