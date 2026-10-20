
import SwiftUI

import SharedKit
import CommonScene
import CommonUIKit
import NavigationCoordinator

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var navigationBinding: UIKitNavigationBinding<Screen>?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        let navigationController: UINavigationController = .init()
        setup(with: navigationController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

}

extension SceneDelegate {

    private func setup(with navigationController: UINavigationController) {
        let navigationBinding = UIKitNavigationBinding<Screen>(
            navigationController: navigationController,
            makeViewController: { screen, navigator in
                UIHostingController(
                    rootView: SceneFactory.makeScene(by: screen)
                        .environment(navigator)
                )
            }
        )
        self.navigationBinding = navigationBinding

        navigationController.setViewControllers(
            [
                SearchScreen.ViewController(
                    navigator: navigationBinding.navigator,
                    viewModel: .init(
                        model: .init(
                            dependency: .init(
                                repository: RepositoryFactory.makeUserRepository()
                            )
                        )
                    )
                )
            ],
            animated: false
        )
    }

}
