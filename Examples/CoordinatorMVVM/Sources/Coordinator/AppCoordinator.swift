import SharedKit
import UIKit

/// 화면 전환의 유일한 주인.
/// ViewModel은 "유저가 선택됐다"는 사실만 이벤트로 알리고,
/// 어떤 화면을 어떻게 띄울지는 전부 Coordinator가 결정한다.
/// 흐름이 여러 개로 늘어나면 자식 Coordinator로 분리해 계층을 만든다.
@MainActor
final class AppCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let repository: UserRepository

    init(
        navigationController: UINavigationController,
        repository: UserRepository
    ) {
        self.navigationController = navigationController
        self.repository = repository
    }

    func start() {
        showSearch()
    }

    private func showSearch() {
        let viewModel = SearchViewModel(dependency: .init(repository: repository))
        viewModel.onUserSelected = { [weak self] user in
            self?.showDetail(for: user)
        }
        navigationController.pushViewController(
            SearchViewController(viewModel: viewModel),
            animated: false
        )
    }

    private func showDetail(for user: User) {
        let viewModel = DetailViewModel(dependency: .init(login: user.login, repository: repository))
        navigationController.pushViewController(
            DetailViewController(viewModel: viewModel),
            animated: true
        )
    }
}
