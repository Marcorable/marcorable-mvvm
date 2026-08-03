import Foundation

/// GitHub REST API 기반 실제 구현.
/// 인증 없이 동작하지만 비로그인 검색 API는 분당 10회 rate limit이 있다.
/// 데모/테스트에는 MockUserRepository를 사용해도 된다.
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
/// 테스트와 프리뷰에서 사용하는 인메모리 구현.
/// `error`를 지정하면 모든 호출이 해당 에러를 던지고, `delay`로 로딩 상태를 관찰할 수 있다.
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

    // MARK: - Sample Data

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
            avatarURL: nil
        ),
        "octodog": UserDetail(
            login: "octodog",
            name: "The Octodog",
            bio: nil,
            followers: 12,
            publicRepos: 1,
            avatarURL: nil
        ),
        "marco": UserDetail(
            login: "marco",
            name: "Marco",
            bio: "MVVM을 다양하게 고민하는 중",
            followers: 42,
            publicRepos: 10,
            avatarURL: nil
        ),
    ]
}
#endif
