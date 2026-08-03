import Combine
import Foundation
import SharedKit

/// @Published 상태를 View(ViewController)가 직접 구독하는 기본형 MVVM.
/// Input/Output transform(UIKit+Transform)과 달리, ViewModel이 상태 프로퍼티 하나를 노출하고
/// View가 `$state`를 sink로 바인딩한다.
@MainActor
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([User])
        case failed(String)
    }

    /// View(ViewController)가 구독하는 유일한 출력
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

        // 이전 Task를 취소하고 잠깐 기다렸다가 실행하는 것으로 디바운스를 구현한다.
        searchTask = Task { [debounce] in
            do {
                try await Task.sleep(for: debounce)
                state = .loading
                let users = try await repository.searchUsers(by: trimmed)
                guard !Task.isCancelled else { return }
                state = .loaded(users)
            } catch is CancellationError {
                // 새 검색어가 들어와 취소된 경우: 아무것도 하지 않는다.
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error.localizedDescription)
            }
        }
    }

    /// 다음 화면의 ViewModel 생성을 담당해, View가 Repository를 몰라도 되게 한다.
    func makeDetailViewModel(for user: User) -> DetailViewModel {
        DetailViewModel(
            dependency: .init(
                login: user.login,
                repository: dependency.repository
            )
        )
    }

}
