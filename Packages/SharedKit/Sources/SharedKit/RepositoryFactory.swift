
public enum RepositoryFactory {

    public static func makeUserRepository() -> UserRepository {
        GitHubUserRepository()
    }

}

#if DEBUG
extension RepositoryFactory {

    public static func makeMockUserRepository() -> UserRepository {
        MockUserRepository()
    }

}
#endif
