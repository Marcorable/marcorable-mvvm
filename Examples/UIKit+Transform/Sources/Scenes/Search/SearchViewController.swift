
import Combine
import SwiftUI

import SharedKit
import CommonScene
import CommonUIKit

final class SearchViewController: UITableViewController {
    private let appCoordinator: AppCoordinator
    private let viewModel: SearchViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    private let querySubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var users: [User] = []

    init(
        appCoordinator: AppCoordinator,
        viewModel: SearchViewModel
    ) {
        self.appCoordinator = appCoordinator
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit + Transform"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "GitHub 유저 검색"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        bind()
        render(.idle)
    }

    private func bind() {
        let output = viewModel.transform(
            SearchViewModel.Input(query: querySubject.eraseToAnyPublisher())
        )
        output.state
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    private func render(_ state: SearchViewModel.State) {
        switch state {
            case .idle:
                users = []
                showMessage("검색어를 입력해보세요")

            case .loading:
                showLoading()

            case .loaded(let loadedUsers):
                users = loadedUsers
                showMessage(loadedUsers.isEmpty ? "결과가 없습니다" : nil)

            case .failed(let message):
                users = []
                showMessage(message)
        }
        tableView.reloadData()
    }

    private func showMessage(_ message: String?) {
        guard let message else {
            tableView.backgroundView = nil
            return
        }
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        tableView.backgroundView = label
    }

    private func showLoading() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }

    // MARK: - UITableViewDataSource / Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = users[indexPath.row].login
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 상세 화면은 CommonScene의 공용 SwiftUI 구현을 호스팅 컨트롤러로 감싸 사용한다.
        navigationController?.pushViewController(
            UIHostingController(
                rootView: SceneFactory.makeScene(by: .detail(users[indexPath.row].login))
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

extension SearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        querySubject.send(searchController.searchBar.text ?? "")
    }

}
