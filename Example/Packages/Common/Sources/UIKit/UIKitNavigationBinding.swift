
import Combine
import UIKit

import NavigationCoordinator

@MainActor
public final class UIKitNavigationBinding<Screen: Hashable> {
    public let navigator: Navigator<Screen>

    private var cancellableSet: Set<AnyCancellable> = .init()

    public convenience init(
        navigationController: UINavigationController,
        makeViewController: @escaping (Screen, Navigator<Screen>) -> UIViewController
    ) {
        self.init(
            navigationController: navigationController,
            navigator: Navigator(),
            makeViewController: makeViewController
        )
    }

    public init(
        navigationController: UINavigationController,
        navigator: Navigator<Screen>,
        makeViewController: @escaping (Screen, Navigator<Screen>) -> UIViewController
    ) {
        self.navigator = navigator
        navigator.actionPublisher
            .sink { [weak navigationController, weak navigator] action in
                guard let navigationController, let navigator else {
                    return
                }
                Self.perform(
                    action,
                    on: navigationController,
                    navigator: navigator,
                    makeViewController: makeViewController
                )
            }
            .store(in: &cancellableSet)
    }

}

extension UIKitNavigationBinding {

    private static func perform(
        _ action: Navigator<Screen>.Action,
        on navigationController: UINavigationController,
        navigator: Navigator<Screen>,
        makeViewController: (Screen, Navigator<Screen>) -> UIViewController
    ) {
        let animated = navigationController.viewIfLoaded?.window != nil

        switch action {
            case .push(let screens):
                guard !screens.isEmpty else {
                    return
                }
                navigationController.setViewControllers(
                    navigationController.viewControllers + makeViewControllers(
                        for: screens,
                        navigator: navigator,
                        makeViewController: makeViewController
                    ),
                    animated: animated
                )

            case .pop(let count):
                let stack = navigationController.viewControllers
                guard count > 0, stack.count > 1 else {
                    return
                }
                let targetIndex = max(0, stack.count - 1 - count)
                navigationController.popToViewController(
                    stack[targetIndex],
                    animated: animated
                )

            case .popToRoot:
                navigationController.popToRootViewController(animated: animated)

            case .restack(let screens):
                guard let root = navigationController.viewControllers.first else {
                    return
                }
                navigationController.setViewControllers(
                    [root] + makeViewControllers(
                        for: screens,
                        navigator: navigator,
                        makeViewController: makeViewController
                    ),
                    animated: animated
                )
        }
    }

    private static func makeViewControllers(
        for screens: [Screen],
        navigator: Navigator<Screen>,
        makeViewController: (Screen, Navigator<Screen>) -> UIViewController
    ) -> [UIViewController] {
        screens.map { makeViewController($0, navigator) }
    }

}
