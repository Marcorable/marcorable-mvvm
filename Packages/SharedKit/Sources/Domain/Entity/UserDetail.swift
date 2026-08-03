import Foundation

/// 상세 화면에 표시되는 유저 정보
public struct UserDetail: Hashable, Sendable {
    public let login: String
    public let name: String?
    public let bio: String?
    public let followers: Int
    public let publicRepos: Int
    public let avatarURL: String?
}

extension UserDetail: Decodable {
    typealias Response = Self
}
