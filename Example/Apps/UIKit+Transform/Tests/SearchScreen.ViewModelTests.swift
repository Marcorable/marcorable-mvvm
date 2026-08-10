
import XCTest
import Combine

import SharedKit

@testable import UIKitTransform

@MainActor
final class SearchScreenViewModelTests: XCTestCase {
    private var cancellableSet: Set<AnyCancellable> = []

    override func tearDown() {
        cancellableSet.removeAll()
        super.tearDown()
    }

    private func makeViewModel(
        _ repository: MockUserRepository = .init()
    ) -> SearchScreen.ViewModel {
        .init(model: .init(dependency: .init(repository: repository)))
    }

    private func makeInput(
        viewLife viewLifeSubject: SearchScreen.ViewLifeSubject = .init(),
        userInput userInputSubject: SearchScreen.UserInputSubject = .init()
    ) -> (
        input: SearchScreen.ViewModel.Input,
        viewLife: SearchScreen.ViewLifeSubject,
        userInput: SearchScreen.UserInputSubject
    ) {
        let input = SearchScreen.ViewModel.Input(
            viewLifePublisher: viewLifeSubject.eraseToAnyPublisher(),
            userInputPublisher: userInputSubject.eraseToAnyPublisher()
        )
        return (input, viewLifeSubject, userInput: userInputSubject)
    }

    private func settle(_ seconds: TimeInterval = 1) {
        let settled = expectation(description: "디바운스 및 요청 경과")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: seconds + 2)
    }
}

extension SearchScreenViewModelTests {

    func testViewDidLoadEmitsSetupStatus() {
        let viewModel = makeViewModel()
        let (input, viewLife, _) = makeInput()
        let output = viewModel.transform(input)

        let setup = expectation(description: "setup 상태 방출")
        output.statusPublisher
            .sink {
                if case .setup = $0 { setup.fulfill() }
            }
            .store(in: &cancellableSet)

        viewLife.send(.viewDidLoad)
        wait(for: [setup], timeout: 2)
    }

    func testQueryEmitsRows() {
        let viewModel = makeViewModel()
        let (input, _, userInput) = makeInput()
        let output = viewModel.transform(input)

        let loaded = expectation(description: "rows 채워짐")
        output.rowsPublisher
            .compactMap({ $0 })
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellableSet)

        userInput.send(.search("octo"))
        wait(for: [loaded], timeout: 2)

        var lastRows: [SearchScreen.Row.Model]?
        output.rowsPublisher
            .sink { lastRows = $0 }
            .store(in: &cancellableSet)
        settle()

        XCTAssertEqual(
            lastRows?.map(\.name),
            ["octocat", "octodog"]
        )
    }

    func testWhitespaceOnlyQueryKeepsRowsNil() {
        let viewModel = makeViewModel()
        let (input, _, userInput) = makeInput()
        let output = viewModel.transform(input)

        var latestRows: [SearchScreen.Row.Model]?
        output.rowsPublisher
            .sink { latestRows = $0 }
            .store(in: &cancellableSet)

        userInput.send(.search("   "))
        settle()

        XCTAssertNil(latestRows)
    }

    func testRapidQueriesTriggerSingleSearch() {
        let viewModel = makeViewModel()
        let (input, _, userInput) = makeInput()
        let output = viewModel.transform(input)

        output.rowsPublisher
            .sink { _ in }
            .store(in: &cancellableSet)

        var loadingCount = 0
        output.isLoadingPublisher
            .filter({ $0 })
            .sink { _ in loadingCount += 1 }
            .store(in: &cancellableSet)

        userInput.send(.search("o"))
        userInput.send(.search("oc"))
        userInput.send(.search("oct"))
        userInput.send(.search("octo"))
        settle()

        XCTAssertEqual(loadingCount, 1)
    }

    func testSelectEmitsRouteStatus() {
        let viewModel = makeViewModel()
        let (input, _, userInput) = makeInput()
        let output = viewModel.transform(input)

        output.rowsPublisher
            .sink { _ in }
            .store(in: &cancellableSet)

        let loaded = expectation(description: "rows 로드 완료")
        output.rowsPublisher
            .compactMap({ $0 })
            .first()
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellableSet)

        userInput.send(.search("octo"))
        wait(for: [loaded], timeout: 2)

        let routed = expectation(description: "route 상태 방출")
        var routeLogin: String?
        output.statusPublisher
            .sink {
                if case .route(.detail(let login)) = $0 {
                    routeLogin = login
                    routed.fulfill()
                }
            }
            .store(in: &cancellableSet)

        userInput.send(.select(0))
        wait(for: [routed], timeout: 2)

        XCTAssertEqual(routeLogin, "octocat")
    }

    func testSelectOutOfBoundsDoesNotCrash() {
        let viewModel = makeViewModel()
        let (input, _, userInput) = makeInput()
        let output = viewModel.transform(input)

        output.rowsPublisher
            .sink { _ in }
            .store(in: &cancellableSet)

        let loaded = expectation(description: "rows 로드 완료")
        output.rowsPublisher
            .compactMap({ $0 })
            .first()
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellableSet)

        userInput.send(.search("octo"))
        wait(for: [loaded], timeout: 2)

        var routed = false
        output.statusPublisher
            .sink {
                if case .route = $0 { routed = true }
            }
            .store(in: &cancellableSet)

        userInput.send(.select(999))
        settle()

        XCTAssertFalse(routed)
    }

}
