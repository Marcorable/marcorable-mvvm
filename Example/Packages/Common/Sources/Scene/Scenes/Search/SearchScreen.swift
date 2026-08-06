
public enum SearchScreen {

    public enum Status: Hashable, Error {
        case idle
        case alert(Alert)

        public enum Alert: Hashable {
            case localized(_ message: String)
        }
    }

}

extension SearchScreen {

    public static var debounce: Int { 600 }

}
