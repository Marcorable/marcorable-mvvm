
import XCTest
import Combine

import SharedKit
import CommonScene

@testable import UIKitPublished

@MainActor
final class SearchScreenViewModelTests: XCTestCase {
    private var cancellableSet: Set<AnyCancellable> = []

    override func tearDown() {
        cancellableSet.removeAll()
        super.tearDown()
    }
}

extension SearchScreenViewModelTests {

    func testQueryTriggersSearchAfterDebounce() {
        let viewModel = SearchScreen.ViewModel(model: .mock)
        let loaded = expectation(description: "users 채워짐")

        viewModel.$rows
            .compactMap({ $0 })
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellableSet)

        viewModel.reduce(by: .input("octo"))

        wait(for: [loaded], timeout: 2)
        XCTAssertEqual(
            viewModel.rows?.map(\.name),
            ["octocat", "octodog"]
        )
    }

    func testRapidQueriesTriggerSingleSearch() {
        let viewModel = SearchScreen.ViewModel(model: .mock)
        var loadingCount = 0

        viewModel.$isLoading
            .filter({ $0 })
            .sink { _ in loadingCount += 1 }
            .store(in: &cancellableSet)

        viewModel.reduce(by: .input("o"))
        viewModel.reduce(by: .input("oc"))
        viewModel.reduce(by: .input("oct"))
        viewModel.reduce(by: .input("octo"))

        let debounced = expectation(description: "디바운스 경과")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            debounced.fulfill()
        }
        wait(for: [debounced], timeout: 2)

        XCTAssertEqual(loadingCount, 1)
    }

    func testWhitespaceOnlyQueryKeepsBoardEmpty() {
        let viewModel = SearchScreen.ViewModel(model: .mock)

        viewModel.reduce(by: .input("   "))

        let debounced = expectation(description: "디바운스 경과")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            debounced.fulfill()
        }
        wait(for: [debounced], timeout: 2)

        XCTAssertNil(viewModel.rows)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSelectRowRoutesToDetail() {
        let viewModel = SearchScreen.ViewModel(model: .mock)
        let loaded = expectation(description: "users 채워짐")

        viewModel.$rows
            .compactMap({ $0 })
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellableSet)

        viewModel.reduce(by: .input("octo"))
        wait(for: [loaded], timeout: 2)

        viewModel.reduce(by: .select(1))

        XCTAssertEqual(viewModel.route, .detail("octodog"))
    }

    func testSelectOutOfRangeDoesNotRoute() {
        let viewModel = SearchScreen.ViewModel(model: .mock)

        viewModel.reduce(by: .select(0))

        XCTAssertNil(viewModel.route)
    }

}
