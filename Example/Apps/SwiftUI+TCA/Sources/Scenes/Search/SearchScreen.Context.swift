
import SwiftUI

import CommonScene
import ComposableArchitecture

extension SearchScreen {

    struct Context: View {
        @Bindable var store: StoreOf<Feature>

        @Environment(\.mainStack) var mainStackAction

        var body: some View {
            Group {
                if store.query.trimmingCharacters(in: .whitespaces).isEmpty {
                    ContentUnavailableView(
                        "검색어를 입력해보세요",
                        systemImage: "magnifyingglass"
                    )
                } else if store.isLoading {
                    ProgressView()
                } else if let rows = store.rows {
                    if rows.isEmpty {
                        ContentUnavailableView.search
                    } else {
                        List(rows.indices, id: \.self) { index in
                            Button(
                                action: { store.send(.selectRow(index)) },
                                label: {
                                    AsyncImageLabelRow(model: rows[index])
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("SwiftUI + TCA")
            .searchable(
                text: .init(
                    get: { store.query },
                    set: { store.send(.queryChanged($0)) }
                ),
                prompt: "GitHub 유저 검색"
            )
            .alert($store.scope(state: \.alert, action: \.alert))
            .onChange(of: store.route, initial: false) { oldValue, newValue in
                guard oldValue == nil, let screen = newValue else {
                    return
                }
                mainStackAction(.push(contentsOf: [screen]))
            }
        }
    }

}

#if DEBUG
#Preview {
    NavigationStack {
        SearchScreen.Context(
            store: Store(
                initialState: SearchScreen.Feature.State()
            ) {
                SearchScreen.Feature(model: .mock)
            }
        )
    }
}
#endif
