
import SwiftUI
import Combine

import SharedKit
import CommonUIKit
import CommonScene
import NavigationCoordinator

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var cancellableSet: Set<AnyCancellable> = .init()

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

    private func setup(with navigationController: UINavigationController) { /// Presentation Module
        let navigator: Navigator<Screen> = .init()
        let actionPublisher = navigator.actionPublisher

        actionPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                switch $0 {
                    case .push(let screens):
                        guard !screens.isEmpty else {
                            return
                        }
                        let vcs = screens.map({
                            UIHostingController(
                                rootView: SceneFactory.makeScene(by: $0)
                                    .environment(navigator)
                            )
                        })
                        navigationController.setViewControllers(
                            navigationController.viewControllers + vcs,
                            animated: true
                        )

                    case .pop(let count):
                        let stack = navigationController.viewControllers
                        guard count > 0, stack.count > 1 else {
                            return
                        }
                        let targetIndex = max(0, stack.count - 1 - count)
                        navigationController.popToViewController(
                            stack[targetIndex],
                            animated: true
                        )

                    case .popToRoot:
                        navigationController.popToRootViewController(animated: true)

                    case .restack(let screens):
                        guard let root = navigationController.viewControllers.first else {
                            return
                        }
                        let vcs = screens.map({
                            UIHostingController(
                                rootView: SceneFactory.makeScene(by: $0)
                                    .environment(navigator)
                            )
                        })
                        navigationController.setViewControllers(
                            [root] + vcs,
                            animated: true
                        )
                }
            }
            .store(in: &cancellableSet)

        navigationController.setViewControllers(
            [
                SearchScreen.ViewController(
                    navigator: navigator,
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
