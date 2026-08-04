
import SwiftUI

import SharedKit
import CommonScene

@main
struct SwiftUIPublishedApp: App {

    var body: some Scene {
        WindowGroup {
            MainNavigationStack(
                rootView: SearchView(
                    viewModel: SearchViewModel(
                        dependency: .init(
                            repository: RepositoryFactory.makeUserRepository()
                        )
                    )
                )
            )
        }
    }

}
