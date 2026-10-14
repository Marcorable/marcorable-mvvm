
import XCTest
import ComposableArchitecture

import SharedKit

@testable import SwiftUITCA

@MainActor
final class SearchScreenFailurePolicyTests: XCTestCase {

    func testFailureKeepsPreviousRowsAndPresentsAlert() async {
        let repository = MockUserRepository()
        let clock = TestClock()
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(
                model: .init(dependency: .init(repository: repository))
            )
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.queryChanged("octo")) {
            $0.query = "octo"
        }
        await clock.advance(by: .milliseconds(SearchScreen.debounce))
        await store.receive(\.search) {
            $0.isLoading = true
        }
        await store.receive(\.searchResponse) {
            $0.isLoading = false
            $0.rows = [
                .init(name: "octocat", imageUrl: nil),
                .init(name: "octodog", imageUrl: nil),
            ]
        }

        repository.error = SharedKitError.invalidResponse
        await store.send(.queryChanged("swift")) {
            $0.query = "swift"
        }
        await clock.advance(by: .milliseconds(SearchScreen.debounce))
        await store.receive(\.search) {
            $0.isLoading = true
        }
        await store.receive(\.searchResponse) {
            $0.isLoading = false
            $0.alert = AlertState {
                TextState("불러오기 실패")
            } message: {
                TextState(SharedKitError.invalidResponse.localizedDescription)
            }
        }
    }

    func testRecoversAfterFailure() async {
        let repository = MockUserRepository()
        let clock = TestClock()
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(
                model: .init(dependency: .init(repository: repository))
            )
        } withDependencies: {
            $0.continuousClock = clock
        }

        repository.error = SharedKitError.invalidResponse
        await store.send(.queryChanged("octo")) {
            $0.query = "octo"
        }
        await clock.advance(by: .milliseconds(SearchScreen.debounce))
        await store.receive(\.search) {
            $0.isLoading = true
        }
        await store.receive(\.searchResponse) {
            $0.isLoading = false
            $0.alert = AlertState {
                TextState("불러오기 실패")
            } message: {
                TextState(SharedKitError.invalidResponse.localizedDescription)
            }
        }

        await store.send(.alert(.dismiss)) {
            $0.alert = nil
        }

        repository.error = nil
        await store.send(.queryChanged("octod")) {
            $0.query = "octod"
        }
        await clock.advance(by: .milliseconds(SearchScreen.debounce))
        await store.receive(\.search) {
            $0.isLoading = true
        }
        await store.receive(\.searchResponse) {
            $0.isLoading = false
            $0.rows = [
                .init(name: "octodog", imageUrl: nil),
            ]
        }
    }

    func testEmptyQueryResetsRowsToNil() async {
        let repository = MockUserRepository()
        let clock = TestClock()
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(
                model: .init(dependency: .init(repository: repository))
            )
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.queryChanged("octo")) {
            $0.query = "octo"
        }
        await clock.advance(by: .milliseconds(SearchScreen.debounce))
        await store.receive(\.search) {
            $0.isLoading = true
        }
        await store.receive(\.searchResponse) {
            $0.isLoading = false
            $0.rows = [
                .init(name: "octocat", imageUrl: nil),
                .init(name: "octodog", imageUrl: nil),
            ]
        }

        await store.send(.queryChanged("")) {
            $0.query = ""
            $0.rows = nil
        }
    }

}
