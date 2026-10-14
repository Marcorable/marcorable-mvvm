
import Foundation

import SharedKit
import CommonScene
import ComposableArchitecture

extension SearchScreen {

    @Reducer
    struct Feature {

        @ObservableState
        struct State: Equatable {
            var query = ""
            var rows: [AsyncImageLabelRow.Model]? = nil
            var isLoading = false
            var route: Screen? = nil
            @Presents var alert: AlertState<Action.Alert>?
        }

        enum Action: Equatable {
            case queryChanged(String)
            case search
            case searchResponse(Result<[User], SearchScreen.Status>)
            case selectRow(Int)
            case alert(PresentationAction<Alert>)

            @CasePathable
            enum Alert: Equatable {
                
            }
        }

        private enum CancelID {
            case debounce
        }

        let model: Model

        @Dependency(\.continuousClock) var clock

        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                    case .queryChanged(let text):
                        state.query = text
                        let trimmed = text.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else {
                            state.rows = nil
                            state.isLoading = false
                            return .cancel(id: CancelID.debounce)
                        }
                        return .run { send in
                            try await clock.sleep(for: .milliseconds(SearchScreen.debounce))
                            await send(.search)
                        }
                        .cancellable(id: CancelID.debounce, cancelInFlight: true)

                    case .search:
                        state.isLoading = true
                        let query = state.query.trimmingCharacters(in: .whitespaces)
                        return .run { [model] send in
                            let result = await model.search(by: query)
                            await send(.searchResponse(result))
                        }

                    case .searchResponse(let result):
                        state.isLoading = false
                        switch result {
                            case .success(let users):
                                state.rows = users.map {
                                    .init(
                                        name: $0.login,
                                        imageUrl: $0.avatarURL.flatMap(URL.init(string:))
                                    )
                                }
                            case .failure(let status):
                                switch status {
                                    case .idle:
                                        break
                                    case .alert(.localized(let message)):
                                        state.alert = AlertState {
                                            TextState("불러오기 실패")
                                        } message: {
                                            TextState(message)
                                        }
                                }
                        }
                        return .none

                    case .selectRow(let index):
                        guard let row = state.rows?[safe: index] else {
                            return .none
                        }
                        state.route = .detail(row.name)
                        return .none

                    case .alert:
                        return .none
                }
            }
            .ifLet(\.$alert, action: \.alert)
        }

    }

}
