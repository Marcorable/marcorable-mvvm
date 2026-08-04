
import SwiftUI

import SharedKit
import CommonScene

@main
struct SwiftUIObservableApp: App {

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
