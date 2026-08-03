import Foundation

/// URL 요청 → 상태코드 검증 → 디코딩의 공통 흐름을 제공한다.
/// associatedtype 대신 제네릭 메서드를 사용해, 한 타입이 여러 Response 타입을 요청할 수 있게 한다.
protocol RequestFeature {
    var session: URLSession { get }
}

extension RequestFeature {

    func request<Response: Decodable>(_ url: URL?) async throws -> Response {
        guard let url else {
            throw SharedKitError.urlBindingFailed
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SharedKitError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw SharedKitError.httpStatus(http.statusCode)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: data)
    }

}
