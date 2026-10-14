
import SwiftUI

import SharedKit
import CommonScene
import ComposableArchitecture

@main
struct SwiftUITCAApp: App {

    var body: some Scene {
        WindowGroup {
            MainNavigationStack(
                rootView: SearchScreen.Context(
                    store: Store(
                        initialState: SearchScreen.Feature.State(),
                        reducer: {
                            SearchScreen.Feature(
                                model: .init(
                                    dependency: .init(
                                        repository: RepositoryFactory.makeUserRepository()
                                    )
                                )
                            )
                        }
                    )
                )
            )
        }
    }

}
