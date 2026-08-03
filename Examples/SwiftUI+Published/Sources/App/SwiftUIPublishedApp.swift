import SharedKit
import SwiftUI

@main
struct SwiftUIPublishedApp: App {
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
