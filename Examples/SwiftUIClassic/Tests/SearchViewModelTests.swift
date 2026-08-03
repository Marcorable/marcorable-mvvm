import SharedKit
import XCTest

@testable import SwiftUIClassic

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testQueryChangeLoadsUsers() async throws {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()), debounceMilliseconds: 0)

        viewModel.query = "octo"

        // 디바운스(main queue 경유)가 흐르도록 잠깐 양보한 뒤 검색 Task를 기다린다.
        try await waitForSearchTask(of: viewModel)
        XCTAssertEqual(viewModel.state, .loaded([
            User(id: 1, login: "octocat"),
            User(id: 2, login: "octodog"),
        ]))
    }

    func testEmptyQueryResetsToIdle() async throws {
        let viewModel = SearchViewModel(dependency: .init(repository: MockUserRepository()), debounceMilliseconds: 0)

        viewModel.query = "octo"
        try await waitForSearchTask(of: viewModel)

        viewModel.query = ""
        try await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testFailureSetsFailedState() async throws {
        let repository = MockUserRepository(error: SharedKitError.httpStatus(500))
        let viewModel = SearchViewModel(dependency: .init(repository: repository), debounceMilliseconds: 0)

        viewModel.query = "octo"
        try await waitForSearchTask(of: viewModel)

        guard case .failed = viewModel.state else {
            return XCTFail("상태는 .failed여야 한다: \(viewModel.state)")
        }
    }

    /// 디바운스가 DispatchQueue.main을 경유하므로, 검색 Task가 만들어질 때까지 잠깐 기다린다.
    private func waitForSearchTask(of viewModel: SearchViewModel) async throws {
        for _ in 0..<50 {
            if let task = viewModel.searchTask {
                await task.value
                return
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("검색 Task가 생성되지 않았다")
    }
}
