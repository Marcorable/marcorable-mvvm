
import Foundation

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

        do {
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
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        }
    }

}
