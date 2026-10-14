
import XCTest
import ComposableArchitecture

import SharedKit

@testable import SwiftUITCA

@MainActor
final class SearchScreenFeatureTests: XCTestCase {

    func testSearchLoadsRows() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(model: .mock)
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
    }

    func testWhitespaceOnlyQueryKeepsRowsNil() async {
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(model: .mock)
        }

        await store.send(.queryChanged("   ")) {
            $0.query = "   "
        }
    }

    func testRapidQueriesDebounce() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(model: .mock)
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.queryChanged("o")) {
            $0.query = "o"
        }
        await store.send(.queryChanged("oc")) {
            $0.query = "oc"
        }
        await store.send(.queryChanged("oct")) {
            $0.query = "oct"
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
    }

    func testSelectRowEmitsRoute() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(model: .mock)
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

        await store.send(.selectRow(0)) {
            $0.route = .detail("octocat")
        }
    }

    func testSelectOutOfBoundsDoesNothing() async {
        let store = TestStore(
            initialState: SearchScreen.Feature.State()
        ) {
            SearchScreen.Feature(model: .mock)
        }

        await store.send(.selectRow(999))
    }

}
