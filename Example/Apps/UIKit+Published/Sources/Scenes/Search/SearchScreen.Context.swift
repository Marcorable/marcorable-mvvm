
import SwiftUI

import CommonScene

extension SearchScreen {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias Row = AsyncImageLabelRow

    enum Section: Int, Hashable {
        case main
    }

    enum Item: Hashable {
        case row(_ model: Row.Model)
    }

    final class Context: UITableView {

        private let spinner: UIActivityIndicatorView = .init(style: .medium)

        private let intentSubject: IntentSubject = .init()

        var intentPublisher: IntentPublisher {
            intentSubject.eraseToAnyPublisher()
        }
    }

    static var cellProvider: DataSource.CellProvider {
        { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
                case .row(let model):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    cell.contentConfiguration = UIHostingConfiguration {
                        Row(model: model)
                    }
                    cell.accessoryType = .disclosureIndicator
                    return cell
            }
        }
    }

}

extension SearchScreen.Context {

    func setup(searchController: UISearchController) {
        self.setupAttribute(searchController: searchController)
        self.setupLayout()
    }

    private func setupAttribute(
        searchController: UISearchController
    ) {
        self.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.delegate = self
        searchController.searchResultsUpdater = self

        self.spinner.isHidden = true
    }

    private func setupLayout() {
        self.backgroundView = spinner
    }

}

extension SearchScreen.Context {

    func showLoading(_ isShow: Bool) {
        switch isShow {
            case true:
                spinner.startAnimating()
                self.spinner.isHidden = false

            case false:
                spinner.stopAnimating()
                self.spinner.isHidden = true
        }
    }

}

extension SearchScreen.Context: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        self.deselectRow(at: indexPath, animated: true)
        self.intentSubject.send(.select(indexPath.row))
    }

}

extension SearchScreen.Context: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        self.intentSubject.send(.input(query))
    }

}
