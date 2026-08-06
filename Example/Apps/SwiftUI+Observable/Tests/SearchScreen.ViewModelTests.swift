
import XCTest

import SharedKit

@testable import SwiftUIObservable

@MainActor
final class SearchScreenViewModelTests: XCTestCase {

    private func makeViewModel(
        _ repository: MockUserRepository = MockUserRepository()
    ) -> SearchScreen.ViewModel {
        .init(model: .init(dependency: .init(repository: repository)))
    }

}

extension SearchScreenViewModelTests {

    func testSearchLoadsRows() async {
        let viewModel = makeViewModel()

        viewModel.input = "octo"
        await viewModel.search()

        XCTAssertEqual(
            viewModel.rows?.map(\.name),
            ["octocat", "octodog"]
        )
        XCTAssertFalse(viewModel.isLoading)
    }

    func testWhitespaceOnlyInputKeepsBoardEmpty() async {
        let viewModel = makeViewModel()

        viewModel.input = "   "
        await viewModel.search()

        XCTAssertNil(viewModel.rows)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFailurePresentsAlert() async {
        let viewModel = makeViewModel(
            MockUserRepository(error: SharedKitError.httpStatus(500))
        )

        viewModel.input = "octo"
        await viewModel.search()

        XCTAssertNotNil(viewModel.presentedAlertString)
        XCTAssertFalse(viewModel.isLoading)
    }

}
