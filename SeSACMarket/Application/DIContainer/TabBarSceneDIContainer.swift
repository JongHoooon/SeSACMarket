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
    
    // MARK: - Product LocalRepository
    private lazy var productLocalRepository = DefaultProductLocalRepository()
}

extension TabBarSceneDIContainer: TabBarCoordinatorDependencies {
    
    // MARK: - Tab Bar Scene
    func makeTabBarController() -> UITabBarController {
        return UITabBarController()
    }
    
    // MARK: - Search Scene
    func makeSearchSceneDIContainer() -> SearchSceneDIContainer {
        guard let productLocalRepository = productLocalRepository
        else { fatalError("productLocalRepository is not linked") }
        
        let dependencies = SearchSceneDIContainer.Dependencies(
            apiDataTransferService: dependencies.apiDataTransferService,
            productLocalRepository: productLocalRepository
        )
        return SearchSceneDIContainer(dedepdencies: dependencies)
    }
    
    // MARK: - Favorite Scene
    func makeFavoriteSceneDIContainer() -> FavoriteSceneDIContainer {
        guard let productLocalRepository = productLocalRepository
        else { fatalError("productLocalRepository is not linked") }
        
        let dependencies = FavoriteSceneDIContainer.Dependendcies(prodcutLocalRepository: productLocalRepository)
        return FavoriteSceneDIContainer(dependcencies: dependencies)
    }
    
    // MARK: - Flow Coordinator
    func makeTabBarFlowCoordinator() -> TabBarCoordinator {
        return TabBarCoordinator(
            dependencies: self
        )
    }
}
