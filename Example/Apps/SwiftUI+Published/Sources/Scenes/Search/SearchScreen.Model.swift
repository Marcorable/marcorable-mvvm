
import SharedKit

extension SearchScreen {

    struct Model {
        private let dependency: Dependency

        init(dependency: Dependency) {
            self.dependency = dependency
        }
    }

}

extension SearchScreen.Model {

    struct Dependency {
        let repository: UserRepository
    }

}

extension SearchScreen.Model {
    typealias State = SearchScreen.State

    func search(by trimmed: String) async -> Result<[User], State> {
        guard !trimmed.isEmpty else {
            return .failure(.idle)
        }
        do {
            let users = try await dependency.repository.searchUsers(by: trimmed)
            return .success(users)
        } catch {
            return .failure(.alert(.localized(error.localizedDescription)))
        }
    }

}

#if DEBUG
extension SearchScreen.Model {

    static var mock: Self {
        .init(
            dependency: .init(
                repository: MockUserRepository()
            )
        )
    }

}
#endif
