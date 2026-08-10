
import Combine
import Foundation

import SharedKit
import CommonScene

extension SearchScreen {

    @MainActor
    final class ViewModel {

        struct Input {
            let viewLifePublisher: AnyPublisher<ViewLife, Never>
            let userInputPublisher: AnyPublisher<UserInput, Never>
        }

        struct Output {
            let isLoadingPublisher: AnyPublisher<Bool, Never>
            let rowsPublisher: AnyPublisher<[Row.Model]?, Never>
            let statusPublisher: AnyPublisher<Status, Never>
        }

        private let model: Model

        init(model: Model) {
            self.model = model
        }

    }

}

extension SearchScreen.ViewModel {
    typealias Row = SearchScreen.Row
    typealias Status = SearchScreen.Status

    func transform(_ input: Input) -> Output {
        let isLoadingSubject: PassthroughSubject<Bool, Never> = .init()
        let rowsSubject: CurrentValueSubject<[Row.Model]?, Never> = .init(nil)

        let queryPublisher = query(from: input.userInputPublisher)

        let searched = search(
            from: queryPublisher,
            isLoadingSubject: isLoadingSubject
        )

        return Output(
            isLoadingPublisher: isLoadingSubject.eraseToAnyPublisher(),
            rowsPublisher: rows(
                from: searched.successes(),
                query: queryPublisher,
                isLoadingSubject: isLoadingSubject,
                rowsSubject: rowsSubject
            ),
            statusPublisher: Publishers
                .MergeMany(
                    input.viewLifePublisher
                        .compactMap({ viewLife -> Status? in
                            switch viewLife {
                                case .viewDidLoad:
                                    .setup
                            }
                        })
                        .eraseToAnyPublisher(),
                    select(
                        from: input.userInputPublisher,
                        rowsSubject: rowsSubject
                    ),
                    searched.failures()
                )
                .handleEvents(receiveOutput: { _ in isLoadingSubject.send(false) })
                .eraseToAnyPublisher()
        )
    }

}

extension SearchScreen.ViewModel {

    private func rows(
        from searchedPublisher: AnyPublisher<[User], Never>,
        query queryPublisher: AnyPublisher<String, Never>,
        isLoadingSubject: PassthroughSubject<Bool, Never>,
        rowsSubject: CurrentValueSubject<[Row.Model]?, Never>
    ) -> AnyPublisher<[Row.Model]?, Never> {
        Publishers
            .Merge(
                searchedPublisher.map(\.transform),
                queryPublisher.filter(\.isEmpty).map({ _ in nil })
            )
            .handleEvents(receiveOutput: { _ in isLoadingSubject.send(false) })
            .multicast(subject: rowsSubject)
            .autoconnect()
            .eraseToAnyPublisher()
    }

    private func query(
        from userInputPublisher: SearchScreen.UserInputPublisher
    ) -> AnyPublisher<String, Never> {
        userInputPublisher
            .compactMap({ userInput -> String? in
                guard case .search(let query) = userInput else { return nil }
                return query.trimmingCharacters(in: .whitespaces)
            })
            .removeDuplicates()
            .debounce(for: .milliseconds(SearchScreen.debounce), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func search(
        from queryPublisher: AnyPublisher<String, Never>,
        isLoadingSubject: PassthroughSubject<Bool, Never>
    ) -> AnyPublisher<Result<[User], Status>, Never> {
        queryPublisher
            .filter({ !$0.isEmpty })
            .handleEvents(
                receiveOutput: { _ in isLoadingSubject.send(true) }
            )
            .combineLatest(Just(model).eraseToAnyPublisher())
            .map({ query, model in
                Future<Result<[User], Status>, Never> { promise in
                    Task {
                        let result = await model.search(by: query)
                        promise(.success(result))
                    }
                }
            })
            .switchToLatest()
            .share()
            .eraseToAnyPublisher()
    }

    private func select(
        from userInputPublisher: SearchScreen.UserInputPublisher,
        rowsSubject: CurrentValueSubject<[Row.Model]?, Never>
    ) -> AnyPublisher<Status, Never> {
        userInputPublisher
            .compactMap({ userInput -> Int? in
                guard case .select(let index) = userInput else { return nil }
                return index
            })
            .compactMap({
                rowsSubject.value?[safe: $0]
            })
            .map({
                .route(.detail($0.name))
            })
            .eraseToAnyPublisher()
    }

}

fileprivate extension Array where Element == User {

    var transform: [AsyncImageLabelRow.Model] {
        self.map({
            .init(
                name: $0.login,
                imageUrl: $0.avatarURL.flatMap(URL.init(string:))
            )
        })
    }

}
