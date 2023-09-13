//
//  TabBarCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol TabBarCoordinatorDependencies {
    func makeTabBarController() -> UITabBarController
    func makeSearchSceneDIContainer() -> SearchSceneDIContainer
    func makeFavoriteSceneDIContainer() -> FavoriteSceneDIContainer
}

protocol TabBarCoordinatorDelegate: AnyObject {
    func showAuthScene()
}

final class TabBarCoordinator: CoordinatorProtocol,
                               ChangeRootableProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    weak var delegate: TabBarCoordinatorDelegate?
    private let dependencies: TabBarCoordinatorDependencies
    let navigationController = UINavigationController()
    let type: CoordinatorType = .tabBar

    
    init(dependencies: TabBarCoordinatorDependencies) {
        self.dependencies = dependencies
    }
    
    func start() {
        let tabBarController = dependencies.makeTabBarController()
        
        let searchSceneNavigationController = TabBarEnum.search.configureTabBarItem(navigationController: UINavigationController())
        let favoriteSceneNavigationController = TabBarEnum.favorite.configureTabBarItem(navigationController: UINavigationController())
        
        tabBarController.viewControllers = [
            searchSceneNavigationController,
            favoriteSceneNavigationController
        ]
        
        startSearchScene(navigationController: searchSceneNavigationController)
        startFavoriteScene(navigationController: favoriteSceneNavigationController)
        
        changeWindowRoot(rootViewController: tabBarController)
    }
}

extension TabBarCoordinator: SearchCoordinatorDelegate {
    
}

extension TabBarCoordinator: FavoriteCoordinatorDelegate {
    func showAuth() {
        guard let delegate
        else { fatalError("TabBarCoordinatorDelegate is not linked") }
        delegate.showAuthScene()
    }
}

private extension TabBarCoordinator {
    func startSearchScene(navigationController: UINavigationController) {
        let searchSceneDIContainer = dependencies.makeSearchSceneDIContainer()
        let flow = searchSceneDIContainer.makeSearchSceneCoordinator(navigationController: navigationController)
        flow.delegate = self
        flow.start()
        addChildCoordinator(child: flow)
    }
    func startFavoriteScene(navigationController: UINavigationController) {
        let favoriteSceneDIContainer = dependencies.makeFavoriteSceneDIContainer()
        let flow = favoriteSceneDIContainer.makeFavoriteSceneCoordinator(navigationController: navigationController)
        flow.delegate = self
        flow.start()
        addChildCoordinator(child: flow)
    }
}

