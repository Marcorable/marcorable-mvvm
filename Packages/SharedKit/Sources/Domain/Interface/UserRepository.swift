
import Foundation

public protocol UserRepository: Sendable {
    func searchUsers(by query: String) async throws -> [User]
    func userDetail(login: String) async throws -> UserDetail
}
