
import XCTest
import Combine

import SharedKit

@testable import UIKitTransform

@MainActor
final class SearchScreenFailurePolicyTests: XCTestCase {
    private var cancellableSet: Set<AnyCancellable> = []

    override func tearDown() {
        cancellableSet.removeAll()
        super.tearDown()
    }

    private func makeViewModel(
        _ repository: MockUserRepository
    ) -> SearchScreen.ViewModel {
        .init(model: .init(dependency: .init(repository: repository)))
    }

    private func makeInput(
        userInput userInputSubject: SearchScreen.UserInputSubject = .init()
    ) -> (
        input: SearchScreen.ViewModel.Input,
        userInput: SearchScreen.UserInputSubject
    ) {
        let input = SearchScreen.ViewModel.Input(
            viewLifePublisher: Empty().eraseToAnyPublisher(),
            userInputPublisher: userInputSubject.eraseToAnyPublisher()
        )
        return (input, userInput: userInputSubject)
    }

    private func settle(_ seconds: TimeInterval = 1) {
        let settled = expectation(description: "디바운스 및 요청 경과")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            settled.fulfill()
        }
        wait(for: [settled], timeout: seconds + 2)
    }
}

extension SearchScreenFailurePolicyTests {

    func testFailureEmitsAlertStatus() {
        let repository = MockUserRepository(error: SharedKitError.httpStatus(500))
        let viewModel = makeViewModel(repository)
        let (input, userInput) = makeInput()
        let output = viewModel.transform(input)

        output.rowsPublisher
            .sink { _ in }
            .store(in: &cancellableSet)

        let alerted = expectation(description: "alert 상태 방출")
        output.statusPublisher
            .sink {
                if case .alert = $0 { alerted.fulfill() }
            }
            .store(in: &cancellableSet)

        userInput.send(.search("octo"))
        wait(for: [alerted], timeout: 2)
    }

    func testFailureKeepsPreviousRows() {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)
        let (input, userInput) = makeInput()
        let output = viewModel.transform(input)

        var latestRows: [SearchScreen.Row.Model]?
        output.rowsPublisher
            .sink { latestRows = $0 }
            .store(in: &cancellableSet)

        output.statusPublisher
            .sink { _ in }
            .store(in: &cancellableSet)

        userInput.send(.search("octo"))
        settle()
        XCTAssertEqual(latestRows?.map(\.name), ["octocat", "octodog"])

        repository.error = SharedKitError.invalidResponse

        let alerted = expectation(description: "alert 방출")
        output.statusPublisher
            .sink {
                if case .alert = $0 { alerted.fulfill() }
            }
            .store(in: &cancellableSet)

        userInput.send(.search("swift"))
        wait(for: [alerted], timeout: 2)
        settle()

        XCTAssertEqual(latestRows?.map(\.name), ["octocat", "octodog"])
    }

    func testRecoversAfterFailure() {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)
        let (input, userInput) = makeInput()
        let output = viewModel.transform(input)

        var latestRows: [SearchScreen.Row.Model]?
        output.rowsPublisher
            .sink { latestRows = $0 }
            .store(in: &cancellableSet)

        output.statusPublisher
            .sink { _ in }
            .store(in: &cancellableSet)

        repository.error = SharedKitError.invalidResponse
        userInput.send(.search("octo"))
        settle()

        repository.error = nil
        userInput.send(.search("octod"))
        settle()

        XCTAssertEqual(latestRows?.map(\.name), ["octodog"])
    }

    func testEmptyQueryAfterSearchResetsRowsToNil() {
        let repository = MockUserRepository()
        let viewModel = makeViewModel(repository)
        let (input, userInput) = makeInput()
        let output = viewModel.transform(input)

        var latestRows: [SearchScreen.Row.Model]?
        output.rowsPublisher
            .sink { latestRows = $0 }
            .store(in: &cancellableSet)

        userInput.send(.search("octo"))
        settle()
        XCTAssertEqual(latestRows?.map(\.name), ["octocat", "octodog"])

        userInput.send(.search(""))
        settle()

        XCTAssertNil(latestRows)
    }

}
