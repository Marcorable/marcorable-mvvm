
import Foundation
import Observation

import SharedKit
import CommonScene

extension SearchScreen {

    @MainActor
    @Observable
    final class ViewModel {
        private(set) var input = ""
        private(set) var isLoading: Bool = false
        private(set) var presentedAlertString: String?
        private(set) var route: Screen?

        private(set) var rows: [Row.Model]?

        private var debounceTask: Task<Void, Never>?
        private let model: Model

        init(model: Model) {
            self.model = model
        }
    }

}

extension SearchScreen.ViewModel {
    typealias Intent = SearchScreen.Intent

    func reduce(by intent: Intent) {
        switch intent {
            case .input(let text):
                let previous = self.input
                self.input = text
                guard previous != text else {
                    return
                }
                search(by: text)

            case .dismiss:
                self.presentedAlertString = nil

            case .select(let index):
                guard let row = rows?[safe: index] else {
                    return
                }
                self.route = .detail(row.name)
        }
    }

    private func search(by text: String) {
        let query = text.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            self.debounceTask?.cancel()
            self.rows = nil
            self.isLoading = false
            return
        }

        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(SearchScreen.debounce))
            guard !Task.isCancelled else {
                return
            }
            await MainActor.run {
                self.isLoading = true
            }
            let result = await model.search(by: query)
            await MainActor.run {
                self.isLoading = false
                
                switch result {
                    case .success(let users):
                        self.rows = users
                            .map({
                                .init(
                                    name: $0.login,
                                    imageUrl: $0.avatarURL.flatMap(URL.init(string:))
                                )
                            })
                        
                    case .failure(let status):
                        update(by: status)
                }
            }
        }
    }

}

extension SearchScreen.ViewModel {
    typealias Status = SearchScreen.Status

    typealias Row = AsyncImageLabelRow

    private func update(by status: Status) {
        self.isLoading = false
        self.presentedAlertString = nil

        switch status {
            case .idle:
                break

            case .alert(let alert):
                switch alert {
                    case .localized(let message):
                        self.presentedAlertString = message
                }
        }
    }

}

fileprivate extension AsyncImageLabelRow.Model {

    init(_ user: User) {
        self.init(
            name: user.login,
            imageUrl: user.avatarURL.flatMap(URL.init(string:))
        )
    }

}


#if DEBUG
extension SearchScreen.ViewModel {

    static var mock: SearchScreen.ViewModel {
        .init(model: .mock)
    }

}
#endif
