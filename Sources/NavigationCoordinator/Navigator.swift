
import Combine
import Observation

@MainActor
@Observable
public class Navigator<Screen: Hashable> {
    private let actionSubject: PassthroughSubject<Action, Never> = .init()
    public let actionPublisher: AnyPublisher<Action, Never>

    public init() {
        self.actionPublisher = actionSubject.eraseToAnyPublisher()
    }

}

extension Navigator {

    public enum Action: Hashable {
        case push(contentsOf: [Screen])
        case pop(count: Int = 1)
        case popToRoot
        case restack(contentsOf: [Screen])
    }

    public func push(contentsOf screens: [Screen]) {
        actionSubject.send(.push(contentsOf: screens))
    }

    public func pop(by count: Int) {
        actionSubject.send(.pop(count: count))
    }

    public func popToRoot() {
        actionSubject.send(.popToRoot)
    }

    public func restack(contentsOf screens: [Screen]) {
        actionSubject.send(.restack(contentsOf: screens))
    }

}

extension Navigator: NavigationCoordinator {}
