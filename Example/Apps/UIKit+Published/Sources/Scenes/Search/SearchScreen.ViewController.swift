
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

            bindViewLifeCycle()
            bindInput()
            bindOutput()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

}

extension SearchScreen.ViewController {

    private func bindViewLifeCycle() {
        viewLifeCyclePublisher
            .sink { [weak self] in
                switch $0 {
                    case .loadView:
                        self?.view = self?.context

                    case .viewDidLoad:
                        self?.title = "UIKit + Published"
                        let searchController: UISearchController = .init(searchResultsController: nil)
                        searchController.obscuresBackgroundDuringPresentation = false
                        searchController.searchBar.placeholder = "GitHub 유저 검색"
                        self?.navigationItem.searchController = searchController
                        self?.navigationItem.hidesSearchBarWhenScrolling = false
                        self?.context.setup(searchController: searchController)
                        
                    default:
                        break
                }
            }
            .store(in: &cancellableSet)
    }

    private func bindInput() {
        context.actionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.action(by: $0)
            }
            .store(in: &cancellableSet)
    }

    private func bindOutput() {
        viewModel.$isLoading
            .prepend(false)
            .combineLatest(viewModel.$rows.map({ $0?.isEmpty }))
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

        viewModel.$presentedAlertString
            .compactMap({ $0 })
            .sink { [weak self] message in
                let alertController = UIAlertController(
                    title: "불러오기 실패",
                    message: message,
                    preferredStyle: .alert
                )
                alertController.addAction(.init(title: "확인", style: .default))
                self?.present(alertController, animated: true)
            }
            .store(in: &cancellableSet)

        viewModel.$rows
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

        viewModel.$route
            .compactMap({
                guard case .detail(let login) = $0 else { return nil }
                return login
            })
            .sink { [weak self] in
                self?.navigationController?.pushViewController(
                    UIHostingController(
                        rootView: SceneFactory.makeScene(by: .detail($0))
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
            .store(in: &cancellableSet)
    }

}
