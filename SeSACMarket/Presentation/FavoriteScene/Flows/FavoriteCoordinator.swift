//
//  FavoriteCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

protocol FavoriteCoordinatorDependencies {
    func makeFavoriteViewController(coordinator: FavoriteCoordinator) -> FavoriteViewController
}

protocol FavoriteCoordinatorDelegate: AnyObject {
    func showAuth()
}

protocol FavoriteCoordinator: AnyObject {
    func showDetail(product: Product)
    func showSetting()
}
 
final class DefaultFavoriteCoordinator: CoordinatorProtocol {
    
    private let dependencies: FavoriteCoordinatorDependencies
    weak var delegate: FavoriteCoordinatorDelegate?
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(
        navigationController: UINavigationController,
        dependencies: FavoriteCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func start() {
        let vc = dependencies.makeFavoriteViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

extension DefaultFavoriteCoordinator: FavoriteCoordinator {
    func showDetail(product: Product) {
        let detailDIContainer = DetailSceneDIContainer(product: product)
        let flow = detailDIContainer.makeDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(child: flow)
        flow.delegate = self
        flow.start()
    }
    
    func showSetting() {
        let settingDIContainer = SettingSceneDIContainer()
        let flow = settingDIContainer.makeSettingSceneCoordinator(navigationController: navigationController)
        flow.delegate = self
        addChildCoordinator(child: flow)
        flow.start()
    }
}

extension DefaultFavoriteCoordinator: SettingCoordinatorDelegate {
    func showAuth() {
        guard let delegate = delegate
        else { fatalError("FavoriteCoordinatorDelegate is not linked") }
        finish()
        delegate.showAuth()
    }
}

extension DefaultFavoriteCoordinator: DetailCoordinatorDelegate {
    func finish(child: CoordinatorProtocol) {
        removeChildCoordinator(child: child)
    }
}
