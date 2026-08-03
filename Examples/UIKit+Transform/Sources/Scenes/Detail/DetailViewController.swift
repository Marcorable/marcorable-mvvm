import Combine
import SharedKit
import UIKit

final class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private let stackView = UIStackView()
    private let nameLabel = UILabel()
    private let bioLabel = UILabel()
    private let statsLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .large)

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.login
        view.backgroundColor = .systemBackground
        setUpLayout()

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)

        viewModel.load()
    }

    private func setUpLayout() {
        nameLabel.font = .preferredFont(forTextStyle: .title1)
        bioLabel.font = .preferredFont(forTextStyle: .body)
        bioLabel.textColor = .secondaryLabel
        bioLabel.numberOfLines = 0
        statsLabel.font = .preferredFont(forTextStyle: .footnote)

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        [nameLabel, bioLabel, statsLabel].forEach(stackView.addArrangedSubview)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func render(_ state: DetailViewModel.State) {
        switch state {
            case .loading:
                stackView.isHidden = true
                spinner.startAnimating()

            case .loaded(let detail):
                spinner.stopAnimating()
                stackView.isHidden = false
                nameLabel.text = detail.name ?? detail.login
                bioLabel.text = detail.bio
                statsLabel.text = "팔로워 \(detail.followers) · 공개 저장소 \(detail.publicRepos)"

            case .failed(let message):
                spinner.stopAnimating()
                stackView.isHidden = false
                nameLabel.text = "불러오기 실패"
                bioLabel.text = message
                statsLabel.text = nil
        }
    }
}
