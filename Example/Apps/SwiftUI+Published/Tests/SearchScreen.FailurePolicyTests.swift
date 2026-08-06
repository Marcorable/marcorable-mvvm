
import XCTest
import Combine

import SharedKit

@testable import SwiftUIPublished

@MainActor
final class SearchScreenFailurePolicyTests: XCTestCase {

    private func makeViewModel(
        _ repository: MockUserRepository
    ) -> SearchScreen.ViewModel {
        .init(model: .init(dependency: .init(repository: repository)))
    }

    private func settle(_ seconds: TimeInterval = 1) {
        let settled = expectation(description: "디바운스 및 요청 경과")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: seconds + 2)
    }

}

extension SearchScreenFailurePolicyTests {

    func testFailureKeepsPreviousRowsAndPresentsAlert() {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)

        viewModel.input = "octo"
        settle()
        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])

        repository.error = SharedKitError.invalidResponse
        viewModel.input = "swift"
        settle()

        XCTAssertNotNil(viewModel.presentedAlertString)
        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])
        XCTAssertFalse(viewModel.isLoading)
    }

    func testRecoversAfterFailure() {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)

        repository.error = SharedKitError.invalidResponse
        viewModel.input = "octo"
        settle()
        XCTAssertNotNil(viewModel.presentedAlertString)

        viewModel.presentedAlertString = nil
        repository.error = nil
        viewModel.input = "octod"
        settle()

        XCTAssertEqual(viewModel.rows?.map(\.name), ["octodog"])
        XCTAssertNil(viewModel.presentedAlertString)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testEmptyQueryKeepsRowsAndClearsAlert() {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)

        viewModel.input = "octo"
        settle()
        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])

        viewModel.input = ""
        settle()

        XCTAssertEqual(viewModel.rows?.map(\.name), ["octocat", "octodog"])
        XCTAssertNil(viewModel.presentedAlertString)
        XCTAssertFalse(viewModel.isLoading)
    }

}
