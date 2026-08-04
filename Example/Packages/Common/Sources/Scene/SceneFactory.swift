
import SwiftUI

import SharedKit

public enum SceneFactory {

}

extension SceneFactory {

    @MainActor
    static public func makeScene(by screen: Screen) -> some View {
        switch screen {
            case .detail(let login):
                DetailView(
                    viewModel: DetailViewModel(
                        dependency: .init(
                            login: login,
                            repository: RepositoryFactory.makeUserRepository()
                        )
                    )
                )
        }
    }

}
