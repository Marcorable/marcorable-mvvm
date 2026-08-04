
import UIKit

import SharedKit
import CommonUIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController: UINavigationController = .init()
        let appCoordinator: AppCoordinator = .init(by: navigationController)
        navigationController.setViewControllers(
            [
                SearchViewController(
                    appCoordinator: appCoordinator,
                    viewModel: SearchViewModel(
                        dependency: .init(
                            repository: RepositoryFactory.makeUserRepository()
                        )
                    )
                )
            ],
            animated: false
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
