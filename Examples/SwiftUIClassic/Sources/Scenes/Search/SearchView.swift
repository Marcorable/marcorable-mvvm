import SharedKit
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Content(state: viewModel.state)
            .navigationTitle("SwiftUI + OO")
            .searchable(text: $viewModel.query, prompt: "GitHub 유저 검색")
            .navigationDestination(for: User.self) { user in
                DetailView(viewModel: viewModel.makeDetailViewModel(for: user))
            }
    }
}

extension SearchView {

    struct Content: View {
        let state: SearchViewModel.State

        var body: some View {
            switch state {
                case .idle:
                    ContentUnavailableView("검색어를 입력해보세요", systemImage: "magnifyingglass")

                case .loading:
                    ProgressView()

                case .loaded(let users) where users.isEmpty:
                    ContentUnavailableView.search

                case .loaded(let users):
                    List(users) { user in
                        NavigationLink(value: user) {
                            UserRow(user: user)
                        }
                    }

                case .failed(let message):
                    ContentUnavailableView(
                        label: {
                            Label("불러오기 실패", systemImage: "exclamationmark.triangle")
                        },
                        description: {
                            Text(message)
                        }
                    )
            }
        }
    }

    struct UserRow: View {
        let user: User

        var body: some View {
            HStack(spacing: 12) {
                AsyncImage(
                    url: user.avatarURL.flatMap(URL.init(string:)),
                    content: { image in
                        image.resizable()
                    },
                    placeholder: {
                        Color(.systemFill)
                    }
                )
                .frame(width: 36, height: 36)
                .clipShape(Circle())

                Text(user.login)
            }
        }
    }

}

#Preview {
    NavigationStack {
        SearchView(viewModel: SearchViewModel(dependency: .init(repository: MockUserRepository())))
    }
}
