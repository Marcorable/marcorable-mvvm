
import Foundation
import Observation

import SharedKit
import CommonScene

extension SearchScreen {

    @MainActor
    @Observable
    final class ViewModel {
        var input = ""
        var isLoading: Bool = false
        var presentedAlertString: String?

        private(set) var rows: [Row.Model]?
        private let model: Model

        init(model: Model) {
            self.model = model
        }
    }

}

extension SearchScreen.ViewModel {

    var trimmedInput: String { input.trimmingCharacters(in: .whitespaces) }

    func search() async {
        guard !trimmedInput.isEmpty else {
            return
        }

        self.isLoading = true

        let result = await model.search(by: trimmedInput)

        switch result {
            case .success(let users):
                self.rows = users.map({ .init($0) })
                self.isLoading = false

            case .failure(let status):
                update(by: status)
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
