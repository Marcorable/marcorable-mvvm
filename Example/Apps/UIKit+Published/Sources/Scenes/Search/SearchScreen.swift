
import Combine

enum SearchScreen {
    typealias UserInputSubject = PassthroughSubject<UserInput, Never>
    typealias UserInputPublisher = AnyPublisher<UserInput, Never>

    enum Status: Hashable, Error {
        case idle
        case alert(Alert)

        enum Alert: Hashable {
            case localized(_ message: String)
        }
    }

    enum UserInput: Hashable {
        case select(_ rowAt: Int)
        case search(_ query: String)
    }

}

extension SearchScreen {

    static var debounce: Int { 600 }

}
