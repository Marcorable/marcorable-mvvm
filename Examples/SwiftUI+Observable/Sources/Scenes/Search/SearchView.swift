import CommonScene
import SharedKit
import SwiftUI

struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Content(state: viewModel.state)
            .navigationTitle("SwiftUI + @Observable")
            .searchable(text: $viewModel.query, prompt: "GitHub 유저 검색")
            // 검색어가 바뀔 때마다 이전 Task를 자동 취소하고 새로 시작한다.
            // sleep + 취소가 곧 디바운스가 된다.
            .task(id: viewModel.query) {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                await viewModel.search()
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
                        NavigationLink(value: Screen.detail(user.login)) {
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
