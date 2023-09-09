//
//  TabBarSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class TabBarSceneDIContainer {
    struct Dependencies {
        let apiDataTransferService: APIDataTransferService
    }
    
    private let dependencies: Dependencies
    
    init(dedepdencies: Dependencies) {
        self.dependencies = dedepdencies
    }
    
}

extension TabBarSceneDIContainer: TabBarCoordinatorDependencies {
    
    // MARK: - Tab Bar Scene
    func makeTabBarController() -> UITabBarController {
        return UITabBarController()
    }
    
    // MARK: - Search Scene
    func makeSearchDIContainer() -> SearchSceneDIContainer {
        let dependencies = SearchSceneDIContainer.Dependencies(apiDataTransferService: dependencies.apiDataTransferService)
        return SearchSceneDIContainer(dedepdencies: dependencies)
    }
    
    // MARK: - Flow Coordinator
    func makeTabBarFlowCoordinator() -> TabBarCoordinator {
        return TabBarCoordinator(
            dependencies: self
        )
    }
}
