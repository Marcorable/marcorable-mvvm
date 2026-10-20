
import Combine
import Observation

@MainActor
@Observable
public class Navigator<Screen: Hashable> {
    private let actionSubject: PassthroughSubject<Action, Never> = .init()

    public init() {}

}

extension Navigator {

    public enum Action: Hashable {
        case push(contentsOf: [Screen])
        case pop(count: Int = 1)
        case popToRoot
        case restack(contentsOf: [Screen])
    }

    public var actionPublisher: AnyPublisher<Action, Never> {
        actionSubject.eraseToAnyPublisher()
    }

}

extension Navigator: NavigationCoordinator {

    public func push(contentsOf screens: [Screen]) {
        actionSubject.send(.push(contentsOf: screens))
    }

    public func push(_ screen: Screen) {
        actionSubject.send(.push(contentsOf: [screen]))
    }

    public func pop(by count: Int) {
        actionSubject.send(.pop(count: count))
    }

    public func pop() {
        actionSubject.send(.pop(count: 1))
    }

    public func popToRoot() {
        actionSubject.send(.popToRoot)
    }

    public func restack(contentsOf screens: [Screen]) {
        actionSubject.send(.restack(contentsOf: screens))
    }

}
