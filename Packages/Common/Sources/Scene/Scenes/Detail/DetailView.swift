import SharedKit
import SwiftUI

struct DetailView: View {
    @Environment(\.mainStack) private var mainStack
    @StateObject private var viewModel: DetailViewModel

    // 저장 프로퍼티가 private이면 memberwise init도 private이 되므로 명시한다.
    init(viewModel: DetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
                case .loading:
                    ProgressView()

                case .loaded(let detail):
                    Content(detail: detail)

                case .failed(let message):
                    ContentUnavailableView(
                        label: {
                            Label("불러오기 실패", systemImage: "exclamationmark.triangle")
                        },
                        description: {
                            Text(message)
                        },
                        actions: {
                            Button(
                                action: { mainStack(.pop()) },
                                label: { Text("돌아가기") }
                            )
                        }
                    )
            }
        }
        .navigationTitle(viewModel.login)
        .task {
            await viewModel.load()
        }
    }

}

extension DetailView {

    struct Content: View {
        let detail: UserDetail

        var body: some View {
            List {
                Section {
                    HStack(spacing: 16) {
                        AsyncImage(
                            url: detail.avatarURL.flatMap(URL.init(string:)),
                            content: { image in
                                image.resizable()
                            },
                            placeholder: {
                                Color(.systemFill)
                            }
                        )
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(detail.name ?? detail.login)
                                .font(.title2.bold())
                            if let bio = detail.bio {
                                Text(bio)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section {
                    LabeledContent("팔로워", value: "\(detail.followers)")
                    LabeledContent("공개 저장소", value: "\(detail.publicRepos)")
                }
            }
        }
    }

}

#if DEBUG
#Preview {
    NavigationStack {
        DetailView(
            viewModel: DetailViewModel(
                dependency: .init(
                    login: "octocat",
                    repository: MockUserRepository()
                )
            )
        )
    }
}
#endif
