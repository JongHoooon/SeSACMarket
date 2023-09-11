//
//  DetailSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import UIKit

final class DetailSceneDIContainer {
    
    struct Dependendcies {
        let prodcutLocalRepository: ProductLocalRepository
    }
    
    private let dependencies: Dependendcies
    
    init(dependcencies: Dependendcies) {
        self.dependencies = dependcencies
    }
    
    func makeDetailSceneCoordinator(navigationController: UINavigationController) -> DetailCoordinator {
        return DetailCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
}

extension DetailSceneDIContainer: DetailCoordinatorDependencies {
    
    // MARK: - Use Case
    func makeProductLocalUseCase() -> ProductLocalUseCase {
        return ProductLocalUseCase(productLocalRepository: dependencies.prodcutLocalRepository)
    }
    
    // MARK: - Favorite Scene
    func makeFavoriteViewController() -> FavoriteViewController {
        return FavoriteViewController(viewModel: makeFavoriteViewModel())
    }
    
    func makeFavoriteViewModel() -> FavoriteViewModel {
        return FavoriteViewModel(productLocalUseCase: makeProductLocalUseCase())
    }
}
