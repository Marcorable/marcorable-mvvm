
import Combine
import Foundation

import SharedKit

@MainActor
final class SearchViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded([User])
        case failed(String)
    }

    @Published var query = ""
    @Published private(set) var state: State = .idle

    private let dependency: Dependency
    private var queryObservation: AnyCancellable?
    private(set) var searchTask: Task<Void, Never>?

    init(
        dependency: Dependency,
        debounceMilliseconds: Int = 300
    ) {
        self.dependency = dependency
        queryObservation = $query
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .removeDuplicates()
            .debounce(for: .milliseconds(debounceMilliseconds), scheduler: DispatchQueue.main)
            .sink { [weak self] trimmed in
                self?.search(trimmed)
            }
    }
}

extension SearchViewModel {

    struct Dependency {
        let repository: UserRepository
    }

}

extension SearchViewModel {

    private func search(_ trimmed: String) {
        searchTask?.cancel()

        guard !trimmed.isEmpty else {
            state = .idle
            return
        }

        let repository = dependency.repository

        state = .loading
        searchTask = Task {
            do {
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
