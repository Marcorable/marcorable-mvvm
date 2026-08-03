import Combine
import Foundation
import SharedKit

/// iOS 17 이전까지 SwiftUI MVVM의 표준이던 ObservableObject 방식.
/// @Published 프로퍼티 변경이 objectWillChange를 통해 View를 다시 그린다.
@MainActor
final class SearchViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded([User])
        case failed(String)
    }

    /// View가 양방향 바인딩($viewModel.query)하는 입력
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
        // $query 스트림을 ViewModel 스스로 구독해 디바운스한다.
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

    func makeDetailViewModel(for user: User) -> DetailViewModel {
        DetailViewModel(
            dependency: .init(
                login: user.login,
                repository: dependency.repository
            )
        )
    }

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
