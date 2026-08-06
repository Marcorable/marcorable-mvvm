
import SwiftUI

import CommonScene

extension SearchScreen {

    struct Context: View {
        @StateObject private var viewModel: ViewModel

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
                        List(rows, id: \.name) { row in
                            NavigationLink(value: Screen.detail(row.name)) {
                                AsyncImageLabelRow(model: row)
                            }
                        }
                    }
                }
            }
            .navigationTitle("SwiftUI + Published")
            .searchable(
                text: $viewModel.input,
                prompt: "GitHub 유저 검색"
            )
            .alert(
                "불러오기 실패",
                isPresented: .init(
                    get: { viewModel.presentedAlertString != nil },
                    set: {
                        if !$0 {
                            viewModel.presentedAlertString = nil
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
