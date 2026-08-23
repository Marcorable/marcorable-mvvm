
import Combine

enum SearchScreen {
    typealias ActionSubject = PassthroughSubject<Action, Never>
    typealias ActionPublisher = AnyPublisher<Action, Never>

    enum Status: Hashable, Error {
        case idle
        case alert(Alert)

        enum Alert: Hashable {
            case localized(_ message: String)
        }
    }

    enum Action: Hashable {
        case input(String)
        case dismiss
        case select(_ rowAt: Int)
    }

}

extension SearchScreen {

    static var debounce: Int { 600 }

}
