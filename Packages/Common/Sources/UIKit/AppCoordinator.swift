import NavigationCoordinator
import UIKit

@MainActor
public final class AppCoordinator: ObservableObject {

    // 내비게이션 스택(nav → VC → ViewModel → coordinator)이 코디네이터를 참조하므로,
    // 역방향 참조는 weak으로 두어 순환을 끊는다.
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
