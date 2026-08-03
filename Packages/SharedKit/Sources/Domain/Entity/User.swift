import Foundation

/// 검색 결과 목록에 표시되는 유저 요약 정보
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

    // .convertFromSnakeCase가 avatar_url을 avatarUrl로 변환하므로 그 이름과 매칭한다.
    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarURL = "avatarUrl"
    }

}
