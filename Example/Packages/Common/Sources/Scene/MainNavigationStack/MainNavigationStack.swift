
import SwiftUI

import SharedKit
import NavigationCoordinator

public struct MainNavigationStack<RootView: View>: View {
    let rootView: RootView

    public init(rootView: RootView) {
        self.rootView = rootView
    }

    @State private var path: [Screen] = []
    
    public var body: some View {
        NavigationStack(path: $path) {
            rootView
                .navigationDestination(for: Screen.self) {
                    SceneFactory.makeScene(by: $0)
                }
        }
        .environment(\.mainStack) {
            switch $0 {
                case .push(contentsOf: let screens):
                    path.append(contentsOf: screens)

                case .pop(let count):
                    guard !path.isEmpty else {
                        return
                    }
                    if 1...path.count ~= count {
                        path.removeLast(count)
                    } else if count > path.count {
                        path.removeAll()
                    }

                case .popToRoot:
                    path.removeAll()
            }
        }
    }

}
