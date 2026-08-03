import SharedKit
import XCTest

@testable import UIKitPublished

@MainActor
final class DetailViewModelTests: XCTestCase {
    func testLoadPublishesLoadedDetail() async {
        let viewModel = DetailViewModel(dependency: .init(login: "octocat", repository: MockUserRepository()))

        viewModel.load()
        await viewModel.loadTask?.value

        XCTAssertEqual(viewModel.state, .loaded(MockUserRepository.sampleDetails["octocat"]!))
    }

    func testLoadFailureForUnknownLogin() async {
        let viewModel = DetailViewModel(dependency: .init(login: "nobody", repository: MockUserRepository()))

        viewModel.load()
        await viewModel.loadTask?.value

        guard case .failed = viewModel.state else {
            return XCTFail("상태는 .failed여야 한다: \(viewModel.state)")
        }
    }
}
