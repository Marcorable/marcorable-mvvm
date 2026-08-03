import Combine
import Foundation
import SharedKit

/// 상세 화면은 입력 스트림이 단순해서 @Published 상태 노출 방식을 사용한다.
/// (같은 프로젝트 안에서도 화면 복잡도에 따라 transform 패턴과 혼용할 수 있음을 보여주는 예)
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
