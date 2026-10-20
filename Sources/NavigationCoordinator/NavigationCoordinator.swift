
@MainActor
public protocol NavigationCoordinator {
    associatedtype Screen: Hashable

    func push(contentsOf screens: [Screen])
    func push(_ screen: Screen)
    func pop(by count: Int)
    func pop()
    func popToRoot()
    func restack(contentsOf screens: [Screen])
}
