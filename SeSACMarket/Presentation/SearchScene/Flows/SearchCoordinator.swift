//
//  SearchCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol SearchCoordinatorDependencies {
    func makeSearchViewController() -> SearchViewController
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
        let vc = dependencies.makeSearchViewController()
        navigationController.pushViewController(
            vc,
            animated: true
        )
    }
}
