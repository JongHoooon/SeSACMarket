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
    func pushToDetail(product: Product)
    func presentToSetting()
}
 
final class DefaultFavoriteCoordinator: CoordinatorProtocol {
    
    private let dependencies: FavoriteCoordinatorDependencies
    weak var delegate: FavoriteCoordinatorDelegate?
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol]
    
    init(
        navigationController: UINavigationController,
        dependencies: FavoriteCoordinatorDependencies
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
        childCoordinators = []
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
    func pushToDetail(product: Product) {
        let detailDIContainer = DetailSceneDIContainer(product: product)
        let flow = detailDIContainer.makeDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(child: flow)
        flow.finishDelegate = self
        flow.start()
    }
    
    func presentToSetting() {
        let settingNavigationController = UINavigationController()
        let settingDIContainer = SettingSceneDIContainer()
        let flow = settingDIContainer.makeSettingSceneCoordinator(navigationController: settingNavigationController)
        flow.delegate = self
        flow.finishDelegate = self
        addChildCoordinator(child: flow)
        navigationController.present(settingNavigationController, animated: true)
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

extension DefaultFavoriteCoordinator: CoordinatorFinishDelegate {}
