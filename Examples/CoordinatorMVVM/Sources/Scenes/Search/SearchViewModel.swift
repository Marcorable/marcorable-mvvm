import Foundation
import SharedKit

/// 바인딩은 UIKitClosure와 같지만, 화면 전환의 방향이 다르다.
/// - UIKitClosure: View가 다음 화면을 직접 만들어 push한다.
/// - MVVM-C: ViewModel이 "유저 선택" 이벤트만 방출하고, Coordinator가 전환을 수행한다.
@MainActor
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([User])
        case failed(String)
    }

    var onStateChange: ((State) -> Void)?

    /// 내비게이션 이벤트 출력. Coordinator가 연결한다.
    var onUserSelected: ((User) -> Void)?

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

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

    func didSelect(user: User) {
        onUserSelected?(user)
    }

}
