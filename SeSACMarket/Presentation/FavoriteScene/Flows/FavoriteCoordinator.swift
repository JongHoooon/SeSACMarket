//
//  FavoriteCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

protocol FavoriteCoordinatorDependencies {
    func makeFavoriteViewController() -> FavoriteViewController
}

protocol FavoriteCoordinatorDelegate: AnyObject {
    
}

final class FavoriteCoordinator: CoordinatorProtocol {
    
    private let dependencies: FavoriteCoordinatorDependencies
    weak var delegate: FavoriteCoordinatorDelegate?
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var type: CoordinatorType = .favorite
    
    init(
        navigationController: UINavigationController,
        dependencies: FavoriteCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let vc = dependencies.makeFavoriteViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
