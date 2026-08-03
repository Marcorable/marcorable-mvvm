import SharedKit
import XCTest

@testable import SwiftUIObservable

@MainActor
final class DetailViewModelTests: XCTestCase {
    func testLoadSetsLoadedState() async {
        let viewModel = DetailViewModel(dependency: .init(login: "octocat", repository: MockUserRepository()))

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .loaded(MockUserRepository.sampleDetails["octocat"]!))
    }

    func testLoadFailureSetsFailedState() async {
        let viewModel = DetailViewModel(dependency: .init(login: "nobody", repository: MockUserRepository()))

        await viewModel.load()

        guard case .failed = viewModel.state else {
            return XCTFail("상태는 .failed여야 한다: \(viewModel.state)")
        }
    }
}
