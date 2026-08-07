
import UIKit
import Combine

open class PublishedViewLifeCycleViewController: UIViewController {

    public enum ViewLifeCycle: String, Hashable {
        case loadView
        case viewDidLoad
        case viewWillAppear
        case viewDidAppear
        case viewWillDisappear
        case viewDidDisappear
    }

    public var viewLifeCyclePublisher: AnyPublisher<ViewLifeCycle, Never> {
        viewLifeCycleSubject.eraseToAnyPublisher()
    }

    private let viewLifeCycleSubject: PassthroughSubject<ViewLifeCycle, Never> = .init()
    private var cancellableSet: Set<AnyCancellable> = []

    open override func loadView() {
        super.loadView()
        viewLifeCycleSubject.send(.loadView)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        viewLifeCycleSubject.send(.viewDidLoad)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewLifeCycleSubject.send(.viewWillAppear)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewLifeCycleSubject.send(.viewDidAppear)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewLifeCycleSubject.send(.viewWillDisappear)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewLifeCycleSubject.send(.viewDidDisappear)
    }

}
