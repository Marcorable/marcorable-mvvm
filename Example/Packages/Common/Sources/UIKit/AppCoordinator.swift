
import UIKit

import NavigationCoordinator

@MainActor
public final class AppCoordinator: ObservableObject {

    public weak var navigationController: UINavigationController?

    public init(by navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

}

extension AppCoordinator: NavigationCoordinator {
    public typealias Screen = UIViewController

    public func action(by action: NavigationAction<Screen>) {
        guard let navigationController else {
            return
        }

        switch action {
            case .push(contentsOf: let screens):
                guard !screens.isEmpty else {
                    return
                }
                navigationController.setViewControllers(
                    navigationController.viewControllers + screens,
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
        }
    }

}
