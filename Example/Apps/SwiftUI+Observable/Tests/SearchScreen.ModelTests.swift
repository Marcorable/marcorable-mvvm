
import XCTest

import SharedKit
import CommonScene

@testable import SwiftUIObservable

final class SearchScreenModelTests: XCTestCase {

    private func makeModel(
        _ repository: MockUserRepository = MockUserRepository()
    ) -> SearchScreen.Model {
        .init(dependency: .init(repository: repository))
    }

}

extension SearchScreenModelTests {

    func testSearchReturnsMatchedUsers() async {
        let model = makeModel()

        let result = await model.search(by: "octo")

        XCTAssertEqual(
            try? result.get(),
            [
                User(id: 1, login: "octocat"),
                User(id: 2, login: "octodog"),
            ]
        )
    }

    func testNoMatchReturnsEmptyUsers() async {
        let model = makeModel()

        let result = await model.search(by: "존재하지않는유저")

        XCTAssertEqual(try? result.get(), [])
    }

    func testEmptyQueryFailsWithIdle() async {
        let model = makeModel()

        let result = await model.search(by: "")

        guard case .failure(let status) = result else {
            return XCTFail("빈 검색어는 .idle 실패여야 한다: \(result)")
        }
        XCTAssertEqual(status, .idle)
    }

    func testFailureReturnsAlertStatus() async {
        let model = makeModel(
            MockUserRepository(error: SharedKitError.httpStatus(500))
        )

        let result = await model.search(by: "octo")

        guard case .failure(.alert(.localized(let message))) = result else {
            return XCTFail("실패는 .alert 상태여야 한다: \(result)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func testCancellationFailsWithIdle() async {
        let model = makeModel(MockUserRepository(delay: .seconds(1)))

        let task = Task { await model.search(by: "octo") }
        task.cancel()

        let result = await task.value
        guard case .failure(let status) = result else {
            return XCTFail("취소는 .idle 실패여야 한다: \(result)")
        }
        XCTAssertEqual(status, .idle)
    }

}
