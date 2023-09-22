//
//  TabBarSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class TabBarSceneDIContainer {
    
    func makeTabBarFlowCoordinator(navigationController: UINavigationController) -> TabBarCoordinator {
        return TabBarCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension TabBarSceneDIContainer: TabBarCoordinatorDependencies {
    
    // MARK: - Tab Bar
    func makeTabBarController() -> UITabBarController {
        return UITabBarController()
    }
    
    // MARK: - Search View
    func makeSearchSceneDIContainer() -> SearchSceneDIContainer {
        return SearchSceneDIContainer()
    }
    
    // MARK: - Favorite View
    func makeFavoriteSceneDIContainer() -> FavoriteSceneDIContainer {
        return FavoriteSceneDIContainer()
    }
}
