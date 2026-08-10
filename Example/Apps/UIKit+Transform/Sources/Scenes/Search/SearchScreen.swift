
import Combine

enum SearchScreen {
    typealias ViewLifeSubject = PassthroughSubject<ViewLife, Never>
    typealias UserInputSubject = PassthroughSubject<UserInput, Never>
    typealias UserInputPublisher = AnyPublisher<UserInput, Never>

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

    enum UserInput: Hashable {
        case select(_ rowAt: Int)
        case search(_ query: String)
    }

}

extension SearchScreen {

    static var debounce: Int { 600 }

}
