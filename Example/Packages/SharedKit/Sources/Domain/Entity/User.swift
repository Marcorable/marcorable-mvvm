
import Foundation

public struct User: Identifiable, Hashable, Sendable {
    public let id: Int
    public let login: String
    public let avatarURL: String?

    public init(
        id: Int,
        login: String,
        avatarURL: String? = nil
    ) {
        self.id = id
        self.login = login
        self.avatarURL = avatarURL
    }
}

extension User: Decodable {

    struct Response: Decodable {
        let items: [User]
    }

    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarURL = "avatarUrl"
    }

}
