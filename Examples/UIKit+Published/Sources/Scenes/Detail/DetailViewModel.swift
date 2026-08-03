import Combine
import Foundation
import SharedKit

@MainActor
final class DetailViewModel {
    enum State: Equatable {
        case loading
        case loaded(UserDetail)
        case failed(String)
    }

    @Published private(set) var state: State = .loading

    var login: String { dependency.login }

    private let dependency: Dependency
    private(set) var loadTask: Task<Void, Never>?

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

extension DetailViewModel {

    struct Dependency {
        let login: String
        let repository: UserRepository
    }

}

extension DetailViewModel {

    func load() {
        let repository = dependency.repository
        let login = dependency.login

        loadTask = Task {
            do {
                let detail = try await repository.userDetail(login: login)
                state = .loaded(detail)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error.localizedDescription)
            }
        }
    }

}
