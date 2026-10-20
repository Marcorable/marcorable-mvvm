
@MainActor
public protocol NavigationCoordinator {
    associatedtype Screen: Hashable

    func push(contentsOf screens: [Screen])
    func pop(by count: Int)
    func popToRoot()
    func restack(contentsOf screens: [Screen])
}

extension NavigationCoordinator {

    public func push(_ screen: Screen) {
        push(contentsOf: [screen])
    }

    public func pop() {
        pop(by: 1)
    }

}
