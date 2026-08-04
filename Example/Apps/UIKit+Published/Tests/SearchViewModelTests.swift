
import XCTest
import Combine

import SharedKit

@testable import UIKitPublished

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testSearchPublishesLoadingThenLoaded() async {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()), debounce: .zero)
        var states: [SearchViewModel.State] = []
        viewModel.$state
            .sink { states.append($0) }
            .store(in: &cancellables)

        viewModel.search(query: "octo")
        await viewModel.searchTask?.value

        XCTAssertEqual(states, [
            .idle,
            .loading,
            .loaded([
                User(id: 1, login: "octocat"),
                User(id: 2, login: "octodog"),
            ]),
        ])
    }

    func testEmptyQueryResetsToIdle() {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()), debounce: .zero)

        viewModel.search(query: "   ")

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(viewModel.searchTask)
    }

    func testFailurePublishesFailedState() async {
        let repository = MockUserRepository(error: SharedKitError.httpStatus(500))
        let viewModel = SearchViewModel(dependency: .init(repository: repository), debounce: .zero)

        viewModel.search(query: "octo")
        await viewModel.searchTask?.value

        guard case .failed = viewModel.state else {
            return XCTFail("상태는 .failed여야 한다: \(viewModel.state)")
        }
    }
}
