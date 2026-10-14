
import XCTest

import SharedKit

@testable import SwiftUIObservable

@MainActor
final class SearchScreenViewModelTests: XCTestCase {

    private func settle(_ seconds: TimeInterval = 1) {
        let settled = expectation(description: "디바운스 경과")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: seconds + 2)
    }

}

extension SearchScreenViewModelTests {

    func testQueryTriggersSearchAfterDebounce() {
        let viewModel = SearchScreen.ViewModel(model: .mock)

        viewModel.reduce(by: .input("octo"))
        XCTAssertNil(viewModel.rows)
        settle()

        XCTAssertEqual(
            viewModel.rows?.map(\.name),
            ["octocat", "octodog"]
        )
        XCTAssertFalse(viewModel.isLoading)
    }

    func testRapidQueriesTriggerSingleSearch() {
        let repository = CountingUserRepository()
        let viewModel = SearchScreen.ViewModel(
            model: .init(dependency: .init(repository: repository))
        )

        viewModel.reduce(by: .input("o"))
        viewModel.reduce(by: .input("oc"))
        viewModel.reduce(by: .input("oct"))
        viewModel.reduce(by: .input("octo"))
        settle()

        XCTAssertEqual(repository.queries, ["octo"])
    }

    func testWhitespaceOnlyQueryKeepsBoardEmpty() {
        let viewModel = SearchScreen.ViewModel(model: .mock)

        viewModel.reduce(by: .input("   "))
        settle()

        XCTAssertNil(viewModel.rows)
        XCTAssertFalse(viewModel.isLoading)
    }

}

private final class CountingUserRepository: UserRepository, @unchecked Sendable {
    private let base = MockUserRepository()
    private(set) var queries: [String] = []

    func searchUsers(by query: String) async throws -> [User] {
        queries.append(query)
        return try await base.searchUsers(by: query)
    }

    func userDetail(login: String) async throws -> UserDetail {
        try await base.userDetail(login: login)
    }
}
