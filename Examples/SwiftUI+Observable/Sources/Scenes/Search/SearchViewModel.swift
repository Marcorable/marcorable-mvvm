import Foundation
import Observation
import SharedKit

/// iOS 17+ @Observable 매크로 방식.
/// 프로퍼티 단위로 관찰이 추적되므로 실제로 읽힌 값이 바뀔 때만 View가 갱신된다.
/// Combine 없이 순수 async/await만으로 구성했다 — 디바운스는 View의 .task(id:)가 담당한다.
@MainActor
@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([User])
        case failed(String)
    }

    var query = ""
    private(set) var state: State = .idle

    @ObservationIgnored
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

    /// View의 .task(id: query)에서 호출된다.
    /// 검색어가 바뀌면 SwiftUI가 이전 Task를 취소하고 새로 시작하므로, 취소 관리가 필요 없다.
    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            state = .idle
            return
        }

        let repository = dependency.repository

        state = .loading
        do {
            let users = try await repository.searchUsers(by: trimmed)
            state = .loaded(users)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(error.localizedDescription)
        }
    }

}
