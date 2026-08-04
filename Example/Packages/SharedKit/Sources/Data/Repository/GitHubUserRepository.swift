
import Foundation

public struct GitHubUserRepository: UserRepository, RequestFeature {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    public func searchUsers(by query: String) async throws -> [User] {
        var components = URLComponents(string: "https://api.github.com/search/users")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "30"),
        ]
        let response: User.Response = try await request(components.url)
        return response.items
    }

    public func userDetail(login: String) async throws -> UserDetail {
        let escaped = login.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? login
        let url: URL? = .init(string: "https://api.github.com/users/\(escaped)")
        let userDetail: UserDetail.Response = try await request(url)
        return userDetail
    }

}

#if DEBUG
public final class MockUserRepository: UserRepository, @unchecked Sendable {
    public var users: [User]
    public var details: [String: UserDetail]
    public var error: Error?
    public var delay: Duration

    public init(
        users: [User] = MockUserRepository.sampleUsers,
        details: [String: UserDetail] = MockUserRepository.sampleDetails,
        error: Error? = nil,
        delay: Duration = .zero
    ) {
        self.users = users
        self.details = details
        self.error = error
        self.delay = delay
    }

    public func searchUsers(by query: String) async throws -> [User] {
        try await simulateWork()
        return users.filter { $0.login.localizedCaseInsensitiveContains(query) }
    }

    public func userDetail(login: String) async throws -> UserDetail {
        try await simulateWork()
        guard let detail = details[login] else {
            throw SharedKitError.notFound(login: login)
        }
        return detail
    }

    private func simulateWork() async throws {
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if let error {
            throw error
        }
    }

    public static let sampleUsers: [User] = [
        User(id: 1, login: "octocat", avatarURL: nil),
        User(id: 2, login: "octodog", avatarURL: nil),
        User(id: 3, login: "marco", avatarURL: nil),
    ]

    public static let sampleDetails: [String: UserDetail] = [
        "octocat": UserDetail(
            login: "octocat",
            name: "The Octocat",
            bio: "GitHub의 마스코트",
            followers: 4000,
            publicRepos: 8,
            avatarUrl: nil
        ),
        "octodog": UserDetail(
            login: "octodog",
            name: "The Octodog",
            bio: nil,
            followers: 12,
            publicRepos: 1,
            avatarUrl: nil
        ),
        "marco": UserDetail(
            login: "marco",
            name: "Marco",
            bio: "MVVM을 다양하게 고민하는 중",
            followers: 42,
            publicRepos: 10,
            avatarUrl: nil
        ),
    ]
}
#endif
