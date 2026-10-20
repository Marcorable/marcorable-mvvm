
import UIKit
import XCTest

import NavigationCoordinator

@testable import CommonUIKit

@MainActor
final class UIKitNavigationBindingTests: XCTestCase {

    func testNavigationActionsUpdateViewControllerStack() {
        let root = UIViewController()
        let navigationController = UINavigationController(rootViewController: root)
        let binding = UIKitNavigationBinding<Screen>(
            navigationController: navigationController,
            makeViewController: { screen, _ in
                let viewController = UIViewController()
                viewController.restorationIdentifier = screen.rawValue
                return viewController
            }
        )
        var actions: [Navigator<Screen>.Action] = []
        let cancellable = binding.navigator.actionPublisher
            .sink { actions.append($0) }

        withExtendedLifetime(binding) {
            binding.navigator.push(contentsOf: [.detail, .settings])
            XCTAssertEqual(actions, [.push(contentsOf: [.detail, .settings])])
            XCTAssertEqual(navigationController.viewControllers.count, 3)
            XCTAssertEqual(screens(in: navigationController), [.detail, .settings])

            binding.navigator.pop()
            XCTAssertEqual(navigationController.viewControllers.count, 2)
            XCTAssertEqual(screens(in: navigationController), [.detail])

            binding.navigator.restack(contentsOf: [.settings])
            XCTAssertTrue(navigationController.viewControllers.first === root)
            XCTAssertEqual(screens(in: navigationController), [.settings])

            binding.navigator.popToRoot()
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            XCTAssertTrue(navigationController.viewControllers.first === root)
        }
        withExtendedLifetime(cancellable) {}
    }

    func testBindingAndNavigationControllerAreReleased() {
        weak var weakBinding: UIKitNavigationBinding<Screen>?
        weak var weakNavigationController: UINavigationController?
        weak var weakNavigator: Navigator<Screen>?

        autoreleasepool {
            let navigationController = UINavigationController()
            let binding = UIKitNavigationBinding<Screen>(
                navigationController: navigationController,
                makeViewController: { _, _ in UIViewController() }
            )
            weakBinding = binding
            weakNavigationController = navigationController
            weakNavigator = binding.navigator
        }

        XCTAssertNil(weakBinding)
        XCTAssertNil(weakNavigationController)
        XCTAssertNil(weakNavigator)
    }

}

private extension UIKitNavigationBindingTests {

    enum Screen: String, Hashable {
        case detail
        case settings
    }

    func screens(in navigationController: UINavigationController) -> [Screen] {
        navigationController.viewControllers
            .compactMap(\.restorationIdentifier)
            .compactMap(Screen.init(rawValue:))
    }

}
