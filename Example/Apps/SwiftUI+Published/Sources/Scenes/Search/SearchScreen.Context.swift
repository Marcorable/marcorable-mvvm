
import SwiftUI

import CommonScene

extension SearchScreen {

    struct Context: View {
        @StateObject private var viewModel: ViewModel

        @Environment(\.mainStack) var mainStackAction

        init(viewModel: ViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }

        var body: some View {
            Group {
                if viewModel.input.trimmingCharacters(in: .whitespaces).isEmpty {
                    ContentUnavailableView(
                        "검색어를 입력해보세요",
                        systemImage: "magnifyingglass"
                    )
                } else if viewModel.isLoading {
                    ProgressView()
                } else if let rows = viewModel.rows {
                    if rows.isEmpty {
                        ContentUnavailableView.search
                    } else {
                        List(rows.indices, id: \.self) { index in
                            Button(
                                action: {
                                    viewModel.action(by: .select(index))
                                },
                                label: {
                                    AsyncImageLabelRow(model: rows[index])
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("SwiftUI + Published")
            .searchable(
                text: .init(
                    get: { viewModel.input },
                    set: { viewModel.action(by: .input($0)) }
                ),
                prompt: "GitHub 유저 검색"
            )
            .alert(
                "불러오기 실패",
                isPresented: .init(
                    get: { viewModel.presentedAlertString != nil },
                    set: {
                        if !$0 {
                            viewModel.action(by: .dismiss)
                        }
                    }
                ),
                actions: {

                },
                message: {
                    Text(
                        viewModel.presentedAlertString ?? "알수 없는 에러가 발생했습니다."
                    )
                }
            )
            .onReceive(viewModel.$route.compactMap({ $0 })) {
                mainStackAction(.push(contentsOf: [$0]))
            }
        }
    }

}

#if DEBUG
#Preview {
    NavigationStack {
        SearchScreen.Context(viewModel: .mock)
    }
}
#endif
