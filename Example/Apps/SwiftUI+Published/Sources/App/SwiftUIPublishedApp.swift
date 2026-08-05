
import SwiftUI

import SharedKit
import CommonScene

@main
struct SwiftUIPublishedApp: App {

    var body: some Scene {
        WindowGroup {
            MainNavigationStack(
                rootView: SearchScreen.Context(
                    viewModel: .init(
                        model: .init(
                            dependency: .init(
                                repository: RepositoryFactory.makeUserRepository()
                            )
                        )
                    )
                )
            )
        }
    }

}
