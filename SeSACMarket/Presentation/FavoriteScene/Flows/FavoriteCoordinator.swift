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
    func makeSettingViewController(actions: SettingViewModelActions) -> SettingViewController
    func makeLogoutViewController(actions: LogoutViewModelActions) -> LogoutViewController
}

protocol FavoriteCoordinatorDelegate: AnyObject {
    func showAuth()
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
        let actions = FavoriteViewModelActions(
            showDetail: showDetail(product:),
            showSetting: showSetting
        )
        let vc = dependencies.makeFavoriteViewController(actions: actions)
        navigationController.pushViewController(vc, animated: true)
    }
}

private extension FavoriteCoordinator {
    func showDetail(product: Product) {
        let vc = dependencies.makeDetailViewController(product: product)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSetting() {
        let actions = SettingViewModelActions(showLogout: showLogout)
        let vc = dependencies.makeSettingViewController(actions: actions)
        navigationController.pushViewController(vc, animated: true)
    }
    func showLogout() {
        guard let delegate else { fatalError("FavoriteCoordinatorDelegate is not linked") }
        let actions = LogoutViewModelActions(showAuth: delegate.showAuth)
        let vc = dependencies.makeLogoutViewController(actions: actions)
        navigationController.pushViewController(vc, animated: true)
    }
}
