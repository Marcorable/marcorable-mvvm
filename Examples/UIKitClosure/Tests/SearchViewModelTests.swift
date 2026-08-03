import SharedKit
import XCTest

@testable import UIKitClosure

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testSearchPublishesLoadingThenLoaded() async {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()), debounce: .zero)
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.search(query: "octo")
        await viewModel.searchTask?.value

        XCTAssertEqual(states, [
            .loading,
            .loaded([
                User(id: 1, login: "octocat"),
                User(id: 2, login: "octodog"),
            ]),
        ])
    }

    func testEmptyQueryResetsToIdle() {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()), debounce: .zero)
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.search(query: "   ")

        XCTAssertEqual(states, [.idle])
        XCTAssertNil(viewModel.searchTask)
    }

    func testFailurePublishesFailedState() async {
        let repository = MockUserRepository(error: SharedKitError.httpStatus(500))
        let viewModel = SearchViewModel(dependency: .init(repository: repository), debounce: .zero)
        var states: [SearchViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.search(query: "octo")
        await viewModel.searchTask?.value

        guard case .failed = states.last else {
            return XCTFail("마지막 상태는 .failed여야 한다: \(states)")
        }
    }
}
