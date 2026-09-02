
import Combine
import SwiftUI

import SharedKit
import CommonScene
import CommonUIKit

extension SearchScreen {

    final class ViewController: PublishedViewLifeCycleViewController {
        private let context: Context
        private let dataSource: DataSource
        private let appCoordinator: AppCoordinator
        private let viewModel: ViewModel

        init(
            appCoordinator: AppCoordinator,
            viewModel: ViewModel
        ) {
            let context = Context(
                frame: .zero, 
                style: .insetGrouped
            )
            self.context = context
            self.dataSource = .init(
                tableView: context,
                cellProvider: SearchScreen.cellProvider
            )
            self.appCoordinator = appCoordinator
            self.viewModel = viewModel

            super.init(nibName: nil, bundle: nil)

            bind()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

}

extension SearchScreen.ViewController {

    private func bind() {
        let output = viewModel.transform(
            .init(
                viewLifePublisher: viewLifeCyclePublisher
                    .compactMap({ [weak self] in
                        switch $0 {
                            case .loadView:
                                self?.view = self?.context
                                return nil
                            case .viewDidLoad:
                                return .viewDidLoad
                            default:
                                return nil
                        }
                    })
                    .eraseToAnyPublisher(),
                intentPublisher: context.intentPublisher
            )
        )
        bind(
            isLoading: output.isLoadingPublisher,
            with: output.rowsPublisher
        )
        bind(rows: output.rowsPublisher)
        bind(status: output.statusPublisher)
    }

    private func bind(
        isLoading publisher: AnyPublisher<Bool, Never>,
        with rowsPublisher: AnyPublisher<[SearchScreen.Row.Model]?, Never>
    ) {
        publisher
            .prepend(false)
            .combineLatest(rowsPublisher.map({ $0?.isEmpty }))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading, isEmpty in
                self?.context.showLoading(isLoading)
                if isLoading {
                    self?.contentUnavailableConfiguration = nil
                } else {
                    if let isEmpty = isEmpty {
                        self?.contentUnavailableConfiguration = isEmpty
                        ? UIContentUnavailableConfiguration.search()
                        : nil
                    } else {
                        var configuration = UIContentUnavailableConfiguration.empty()
                        configuration.image = UIImage(systemName: "magnifyingglass")
                        configuration.text = "검색어를 입력해보세요"
                        self?.contentUnavailableConfiguration = configuration
                    }
                }
            }
            .store(in: &cancellableSet)
    }

    private func bind(rows Publisher: AnyPublisher<[SearchScreen.Row.Model]?, Never>) {
        Publisher
            .receive(on: DispatchQueue.main)
            .map({ $0 ?? [] })
            .sink { [weak self] in
                var snapshot = SearchScreen.Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(
                    $0.map({ .row($0) }),
                    toSection: .main
                )
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellableSet)
    }

    private func bind(status publsiher: AnyPublisher<SearchScreen.Status, Never>) {
        publsiher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                switch $0 {
                    case .idle:
                        break

                    case .setup:
                        self?.title = "UIKit + Transform"
                        let searchController: UISearchController = .init(searchResultsController: nil)
                        searchController.obscuresBackgroundDuringPresentation = false
                        searchController.searchBar.placeholder = "GitHub 유저 검색"
                        self?.navigationItem.searchController = searchController
                        self?.navigationItem.hidesSearchBarWhenScrolling = false
                        self?.context.setup(searchController: searchController)

                    case .alert(let alert):
                        switch alert {
                            case .localized(let message):
                                let alertController = UIAlertController(
                                    title: "불러오기 실패",
                                    message: message,
                                    preferredStyle: .alert
                                )
                                alertController.addAction(.init(title: "확인", style: .default))
                                self?.present(alertController, animated: true)
                        }

                    case .route(let route):
                        switch route {
                            case .detail(let login):
                                self?.navigationController?.pushViewController(
                                    UIHostingController(
                                        rootView: SceneFactory.makeScene(by: .detail(login))
                                            .environment(\.mainStack) { [weak self] in
                                                switch $0 {
                                                    case .push(contentsOf: let screens):
                                                        self?.appCoordinator.action(
                                                            by: .push(
                                                                contentsOf: screens.map({
                                                                    UIHostingController(
                                                                        rootView: SceneFactory.makeScene(by: $0)
                                                                    )
                                                                })
                                                            )
                                                        )

                                                    case .pop(let count):
                                                        self?.appCoordinator.action(by: .pop(count: count))

                                                    case .popToRoot:
                                                        self?.appCoordinator.action(by: .popToRoot)
                                                }
                                            }
                                    ),
                                    animated: true
                                )
                        }

                }
            }
            .store(in: &cancellableSet)
    }

}
