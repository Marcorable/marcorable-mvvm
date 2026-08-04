
@MainActor
public protocol NavigationCoordinator: AnyObject {
    associatedtype Screen: Hashable

    func action(by action: NavigationAction<Screen>)
}
