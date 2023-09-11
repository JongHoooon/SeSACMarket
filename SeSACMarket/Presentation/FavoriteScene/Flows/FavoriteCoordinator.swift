//
//  FavoriteCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

protocol FavoriteCoordinatorDependencies {
    func makeFavoriteViewController(actions: FavoriteViewModelActions) -> FavoriteViewController
    func makeDetailViewController(product: Product) -> DetailViewController
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
        let actions = FavoriteViewModelActions(showDetail: showDetail(product:))
        let vc = dependencies.makeFavoriteViewController(actions: actions)
        navigationController.pushViewController(vc, animated: true)
    }
}

private extension FavoriteCoordinator {
    func showDetail(product: Product) {
        let vc = dependencies.makeDetailViewController(product: product)
        navigationController.pushViewController(vc, animated: true)
    }
}
