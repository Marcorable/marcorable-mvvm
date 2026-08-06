
import XCTest

import SharedKit

@testable import SwiftUIObservable

@MainActor
final class SearchScreenFailurePolicyTests: XCTestCase {

    private func makeViewModel(
        _ repository: MockUserRepository
    ) -> SearchScreen.ViewModel {
        .init(model: .init(dependency: .init(repository: repository)))
    }

}

extension SearchScreenFailurePolicyTests {

    func testFailureKeepsPreviousRowsAndPresentsAlert() async {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)

        viewModel.input = "octo"
        await viewModel.search()
        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])

        repository.error = SharedKitError.invalidResponse
        viewModel.input = "swift"
        await viewModel.search()

        XCTAssertNotNil(viewModel.presentedAlertString)
        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])
        XCTAssertFalse(viewModel.isLoading)
    }

    func testRecoversAfterFailure() async {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)

        repository.error = SharedKitError.invalidResponse
        viewModel.input = "octo"
        await viewModel.search()
        XCTAssertNotNil(viewModel.presentedAlertString)

        viewModel.presentedAlertString = nil
        repository.error = nil
        viewModel.input = "octod"
        await viewModel.search()

        XCTAssertEqual(viewModel.rows?.map(\.name), ["octodog"])
        XCTAssertNil(viewModel.presentedAlertString)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testEmptyInputKeepsRowsAndAlertUntouched() async {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)

        viewModel.input = "octo"
        await viewModel.search()
        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])

        viewModel.input = ""
        await viewModel.search()

        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])
        XCTAssertNil(viewModel.presentedAlertString)
        XCTAssertFalse(viewModel.isLoading)
    }

}
