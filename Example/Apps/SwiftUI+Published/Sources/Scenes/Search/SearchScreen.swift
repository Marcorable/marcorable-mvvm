
enum SearchScreen {

    enum Status: Hashable, Error {
        case idle
        case alert(Alert)

        enum Alert: Hashable {
            case localized(_ message: String)
        }
    }

    enum Intent: Hashable {
        case input(String)
        case dismiss
        case select(_ rowAt: Int)
    }

}

extension SearchScreen {

    static var debounce: Int { 600 }

}
