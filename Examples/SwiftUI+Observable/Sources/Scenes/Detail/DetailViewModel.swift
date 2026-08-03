import Foundation
import Observation
import SharedKit

@MainActor
@Observable
final class DetailViewModel {
    enum State: Equatable {
        case loading
        case loaded(UserDetail)
        case failed(String)
    }

    private(set) var state: State = .loading

    var login: String { dependency.login }

    @ObservationIgnored
    private let dependency: Dependency

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

    func load() async {
        let repository = dependency.repository
        let login = dependency.login

        state = .loading
        do {
            state = .loaded(try await repository.userDetail(login: login))
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(error.localizedDescription)
        }
    }

}
