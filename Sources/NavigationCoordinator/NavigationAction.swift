
public enum NavigationAction<Screen: Hashable>: Hashable {
    case push(contentsOf: [Screen])
    case pop(count: Int = 1)
    case popToRoot
}
