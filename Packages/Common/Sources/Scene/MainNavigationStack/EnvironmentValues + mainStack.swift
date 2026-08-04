import SwiftUI
import NavigationCoordinator

extension EnvironmentValues {

    @Entry public var mainStack: (NavigationAction<Screen>) -> Void = { _ in }

}
