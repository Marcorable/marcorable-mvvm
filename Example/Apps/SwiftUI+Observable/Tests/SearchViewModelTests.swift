
import XCTest

import SharedKit

@testable import SwiftUIObservable

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testSearchLoadsUsers() async {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()))
        viewModel.query = "octo"

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .loaded([
            User(id: 1, login: "octocat"),
            User(id: 2, login: "octodog"),
        ]))
    }

    func testEmptyQueryResetsToIdle() async {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()))
        viewModel.query = "   "

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .idle)
    }

    func testFailureSetsFailedState() async {
        let repository = MockUserRepository(error: SharedKitError.httpStatus(500))
        let viewModel = SearchViewModel(dependency: .init(repository: repository))
        viewModel.query = "octo"

        await viewModel.search()

        guard case .failed = viewModel.state else {
            return XCTFail("상태는 .failed여야 한다: \(viewModel.state)")
        }
    }
}
