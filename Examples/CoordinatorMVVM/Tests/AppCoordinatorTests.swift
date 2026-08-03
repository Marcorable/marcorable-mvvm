import SharedKit
import UIKit
import XCTest

@testable import CoordinatorMVVM

@MainActor
final class AppCoordinatorTests: XCTestCase {
    func testStartShowsSearchScreen() {
        let navigationController = UINavigationController()
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            repository: MockUserRepository()
        )

        coordinator.start()

        XCTAssertTrue(navigationController.viewControllers.first is SearchViewController)
    }
}
