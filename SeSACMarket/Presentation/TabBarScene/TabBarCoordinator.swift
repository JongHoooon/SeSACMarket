//
//  TabBarCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol TabBarCoordinatorDependencies {
    func makeTabBarController() -> UITabBarController
    func makeSearchDIContainer() -> SearchSceneDIContainer
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
        
        tabBarController.viewControllers = [
            searchSceneNavigationController
        ]
        
        startSearchScene(navigationController: searchSceneNavigationController)
        
        changeWindowRoot(rootViewController: tabBarController)
    }
}

extension TabBarCoordinator: SearchCoordinatorDelegate {
    
}

private extension TabBarCoordinator {
    func startSearchScene(navigationController: UINavigationController) {
        let searchDIContainer = dependencies.makeSearchDIContainer()
        let flow = searchDIContainer.makeSearchSceneDIContainer(navigationController: navigationController)
        flow.delegate = self
        flow.start()
        addChildCoordinator(child: flow)
    }
}

