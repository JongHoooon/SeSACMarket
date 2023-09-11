//
//  SearchCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol SearchCoordinatorDependencies {
    func makeSearchViewController(actions: SearchViewModelActions) -> SearchViewController
    func makeDetailViewController(product: Product) -> DetailViewController
}

protocol SearchCoordinatorDelegate: AnyObject {
    
}

final class SearchCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    weak var delegate: SearchCoordinatorDelegate?
    private let dependencies: SearchCoordinatorDependencies
    let navigationController: UINavigationController
    let type: CoordinatorType = .search
    
    init(
        dependencies: SearchCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    func start() {
        let actions = SearchViewModelActions(
            showDetail: showDetail(product:)
        )
        let vc = dependencies.makeSearchViewController(actions: actions)
        navigationController.pushViewController(
            vc,
            animated: true
        )
    }
}

private extension SearchCoordinator {
    func showDetail(product: Product) {
        let vc = dependencies.makeDetailViewController(product: product)
        navigationController.pushViewController(vc, animated: true)
    }
}
