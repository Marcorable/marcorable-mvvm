import SharedKit
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let repository = RepositoryFactory.makeUserRepository()
        let searchViewController = SearchViewController(
            viewModel: SearchViewModel(dependency: .init(repository: repository))
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: searchViewController)
        window.makeKeyAndVisible()
        self.window = window
    }
}
