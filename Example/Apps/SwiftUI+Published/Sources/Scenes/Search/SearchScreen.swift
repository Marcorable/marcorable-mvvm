
enum SearchScreen {

    enum Status: Hashable, Error {
        case idle
        case alert(Alert)

        enum Alert: Hashable {
            case localized(_ message: String)
        }
    }

}

extension SearchScreen {

    static var debounce: Int { 600 }

}
