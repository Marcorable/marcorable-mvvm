import SharedKit
import XCTest

@testable import UIKitClosure

@MainActor
final class DetailViewModelTests: XCTestCase {
    func testLoadPublishesLoadedDetail() async {
        let viewModel = DetailViewModel(dependency: .init(login: "octocat", repository: MockUserRepository()))
        var states: [DetailViewModel.State] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.load()
        await viewModel.loadTask?.value

        XCTAssertEqual(states.last, .loaded(MockUserRepository.sampleDetails["octocat"]!))
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
