//
//  TabBarSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

struct TabBarSceneDIContainer {
    func makeTabBarFlowCoordinator() -> TabBarCoordinator {
        return TabBarCoordinator(
            dependencies: self
        )
    }
}

extension TabBarSceneDIContainer: TabBarCoordinatorDependencies {
    func makeTabBarController() -> UITabBarController {
        return UITabBarController()
    }
    
    func makeSearchDIContainer() -> SearchSceneDIContainer {
        return SearchSceneDIContainer()
    }
}
