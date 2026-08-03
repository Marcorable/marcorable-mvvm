import Foundation

public enum SharedKitError {
    case system(Error)
    case urlBindingFailed
    case invalidResponse
    case httpStatus(Int)
    case notFound(login: String)
}

extension SharedKitError: LocalizedError {

    public var errorDescription: String? {
        switch self {
            case .system(let error):            "System: \(error.localizedDescription)"
            case .urlBindingFailed:             "URL 이(가) 올바르지 않습니다."
            case .invalidResponse:              "서버 응답을 해석할 수 없습니다."
            case .httpStatus(let code):         "요청이 실패했습니다. (HTTP \(code))"
            case .notFound(let login):          "'\(login)' 유저를 찾을 수 없습니다."
        }
    }

}

extension SharedKitError: Equatable {

    // system(Error)의 Error가 Equatable이 아니라 자동 합성이 불가능하므로 직접 구현한다.
    // system끼리는 NSError 브릿징(domain + code) 기준으로 비교한다.
    public static func == (lhs: SharedKitError, rhs: SharedKitError) -> Bool {
        switch (lhs, rhs) {
            case (.system(let lhsError), .system(let rhsError)):
                (lhsError as NSError) == (rhsError as NSError)

            case (.urlBindingFailed, .urlBindingFailed),
                 (.invalidResponse, .invalidResponse):
                true

            case (.httpStatus(let lhsCode), .httpStatus(let rhsCode)):
                lhsCode == rhsCode

            case (.notFound(let lhsLogin), .notFound(let rhsLogin)):
                lhsLogin == rhsLogin

            default:
                false
        }
    }

}
