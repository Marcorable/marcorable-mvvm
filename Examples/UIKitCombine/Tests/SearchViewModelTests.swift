import Combine
import SharedKit
import XCTest

@testable import UIKitCombine

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testQueryEmitsLoadingThenLoaded() {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()))
        let querySubject = PassthroughSubject<String, Never>()
        let output = viewModel.transform(
            SearchViewModel.Input(query: querySubject.eraseToAnyPublisher())
        )

        var states: [SearchViewModel.State] = []
        let loaded = expectation(description: "loaded 상태 방출")
        output.state
            .sink { state in
                states.append(state)
                if case .loaded = state { loaded.fulfill() }
            }
            .store(in: &cancellables)

        querySubject.send("octo")
        wait(for: [loaded], timeout: 2)

        XCTAssertEqual(states, [
            .loading,
            .loaded([
                User(id: 1, login: "octocat"),
                User(id: 2, login: "octodog"),
            ]),
        ])
    }

    func testEmptyQueryEmitsIdle() {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()))
        let querySubject = PassthroughSubject<String, Never>()
        let output = viewModel.transform(
            SearchViewModel.Input(query: querySubject.eraseToAnyPublisher())
        )

        let idle = expectation(description: "idle 상태 방출")
        var lastState: SearchViewModel.State?
        output.state
            .sink { state in
                lastState = state
                if case .idle = state { idle.fulfill() }
            }
            .store(in: &cancellables)

        querySubject.send("   ")
        wait(for: [idle], timeout: 2)

        XCTAssertEqual(lastState, .idle)
    }

    func testFailureEmitsFailedState() {
        let repository = MockUserRepository(error: SharedKitError.httpStatus(500))
        let viewModel = SearchViewModel(dependency: .init(repository: repository))
        let querySubject = PassthroughSubject<String, Never>()
        let output = viewModel.transform(
            SearchViewModel.Input(query: querySubject.eraseToAnyPublisher())
        )

        let failed = expectation(description: "failed 상태 방출")
        output.state
            .sink { state in
                if case .failed = state { failed.fulfill() }
            }
            .store(in: &cancellables)

        querySubject.send("octo")
        wait(for: [failed], timeout: 2)
    }
}
