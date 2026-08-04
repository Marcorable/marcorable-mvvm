
import XCTest

@testable import SharedKit

final class MockUserRepositoryTests: XCTestCase {
    func testSearchFiltersByLoginCaseInsensitively() async throws {
        let repository = MockUserRepository()

        let result = try await repository.searchUsers(by: "OCTO")

        XCTAssertEqual(result.map(\.login), ["octocat", "octodog"])
    }

    func testUserDetailReturnsMatchingDetail() async throws {
        let repository = MockUserRepository()

        let detail = try await repository.userDetail(login: "octocat")

        XCTAssertEqual(detail.name, "The Octocat")
    }

    func testUserDetailThrowsForUnknownLogin() async {
        let repository = MockUserRepository()

        do {
            _ = try await repository.userDetail(login: "nobody")
            XCTFail("에러가 발생해야 한다")
        } catch {
            XCTAssertEqual(error as? SharedKitError, .notFound(login: "nobody"))
        }
    }

    func testInjectedErrorIsThrown() async {
        let repository = MockUserRepository(error: SharedKitError.httpStatus(500))

        do {
            _ = try await repository.searchUsers(by: "octo")
            XCTFail("에러가 발생해야 한다")
        } catch {
            XCTAssertEqual(error as? SharedKitError, .httpStatus(500))
        }
    }
}
