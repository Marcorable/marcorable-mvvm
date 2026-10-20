import Combine
import XCTest

@testable import NavigationCoordinator

final class NavigatorTests: XCTestCase {

    @MainActor
    func testPublishesNavigationActionsInOrder() {
        let navigator = Navigator<Screen>()
        var actions: [Navigator<Screen>.Action] = []
        let cancellable = navigator.actionPublisher
            .sink { actions.append($0) }

        navigator.push(.detail("marco"))
        navigator.push(contentsOf: [.detail("coda"), .settings])
        navigator.pop()
        navigator.pop(by: 2)
        navigator.popToRoot()
        navigator.restack(contentsOf: [.settings])

        XCTAssertEqual(
            actions,
            [
                .push(contentsOf: [.detail("marco")]),
                .push(contentsOf: [.detail("coda"), .settings]),
                .pop(count: 1),
                .pop(count: 2),
                .popToRoot,
                .restack(contentsOf: [.settings]),
            ]
        )
        withExtendedLifetime(cancellable) {}
    }

}

private extension NavigatorTests {

    enum Screen: Hashable {
        case detail(String)
        case settings
    }

}
