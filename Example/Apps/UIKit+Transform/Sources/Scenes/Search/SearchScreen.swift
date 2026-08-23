
import Combine

enum SearchScreen {
    typealias ViewLifeSubject = PassthroughSubject<ViewLife, Never>
    typealias ActionSubject = PassthroughSubject<Action, Never>
    typealias ActionPublisher = AnyPublisher<Action, Never>

    enum Status: Hashable, Error {
        case idle
        case setup
        case alert(Alert)
        case route(Route)

        enum Alert: Hashable {
            case localized(_ message: String)
        }

        enum Route: Hashable {
            case detail(_ login: String)
        }

    }

    enum ViewLife: Hashable {
        case viewDidLoad
    }

    enum Action: Hashable {
        case select(_ rowAt: Int)
        case search(_ query: String)
    }

}

extension SearchScreen {

    static var debounce: Int { 600 }

}
