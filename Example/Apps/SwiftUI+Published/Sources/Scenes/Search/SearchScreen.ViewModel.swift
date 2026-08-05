
import Combine
import Foundation

import SharedKit

extension SearchScreen {

    final class ViewModel: ObservableObject {
        @Published var input = ""
        @Published var isLoading: Bool = false
        @Published var presentedAlertString: String?

        @Published private(set) var rows: [Row.Model]?
        private let model: Model

        init(model: Model) {
            self.model = model

            bind()
        }

    }

}

extension SearchScreen.ViewModel {
    typealias State = SearchScreen.State
    typealias Row = SearchScreen.Row

    private func bind() {
        let modelPublisher = Just(model).eraseToAnyPublisher()

        let searched = $input
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.isLoading = true
                }
            )
            .combineLatest(modelPublisher)
            .map({ query, model in
                Future<Result<[User], State>, Never> { promise in
                    Task {
                        let result = await model.search(by: query)
                        promise(.success(result))
                    }
                }
            })
            .switchToLatest()
            .share()

        bind(
            rows: searched
                .successes()
                .map(\.transform)
                .eraseToAnyPublisher()
        )
        bind(
            state: Publishers.MergeMany( // 에러 Subscription 추가 가능
                searched.failures()
            )
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.isLoading = false
                    self?.presentedAlertString = nil
                }
            )
            .eraseToAnyPublisher()
        )
    }

    private func bind(state publisher: AnyPublisher<State, Never>) {
        bind(
            alert: publisher
                .compactMap({
                    guard case .alert(let alert) = $0 else { return nil }
                    return alert
                })
                .eraseToAnyPublisher()
        )
    }

    private func bind(alert publisher: AnyPublisher<State.Alert, Never>) {
        publisher
            .compactMap({
                guard case .localized(let message) = $0 else { return nil }
                return message
            })
            .assign(to: &$presentedAlertString)
    }

    private func bind(rows publisher: AnyPublisher<[Row.Model], Never>) {
        publisher
            .map(Optional.some)
            .receive(on: DispatchQueue.main)
            .assign(to: &$rows)

        $rows
            .compactMap({ $0 })
            .map({ _ in false })
            .assign(to: &$isLoading)
    }

}

fileprivate extension Array where Element == User {

    var transform: [SearchScreen.Row.Model] {
        self.map({
            .init(
                name: $0.login,
                imageUrl: $0.avatarURL.flatMap(URL.init(string:))
            )
        })
    }

}

#if DEBUG
extension SearchScreen.ViewModel {

    static var mock: Self {
        .init(model: .mock)
    }

}
#endif
