import SharedKit
import SwiftUI

@main
struct SwiftUIObservableApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SearchView(
                    viewModel: SearchViewModel(
                        dependency: .init(
                            repository: RepositoryFactory.makeUserRepository()
                        )
                    )
                )
            }
        }
    }
}
