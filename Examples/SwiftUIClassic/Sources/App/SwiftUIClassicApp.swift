import SharedKit
import SwiftUI

@main
struct SwiftUIClassicApp: App {
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
