//
//  FavoriteSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

final class FavoriteSceneDIContainer {
    
    struct Dependendcies {
        let prodcutLocalRepository: ProductLocalRepository
    }
    
    private let dependencies: Dependendcies
    
    init(dependcencies: Dependendcies) {
        self.dependencies = dependcencies
    }
    
    func makeFavoriteSceneCoordinator(navigationController: UINavigationController) -> FavoriteCoordinator {
        return FavoriteCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
}
 
extension FavoriteSceneDIContainer: FavoriteCoordinatorDependencies {
    
    // MARK: - Use Cases
    private func makeProductLocalUseCase() -> ProductLocalUseCase {
        return ProductLocalUseCase(productLocalRepository: dependencies.prodcutLocalRepository)
    }
    
    // MARK: - Search Scene
    func makeFavoriteViewController() -> FavoriteViewController {
        return FavoriteViewController(viewModel: makeFavoriteViewModel())
    }
    
    private func makeFavoriteViewModel() -> FavoriteViewModel {
        return DefaultFavoriteViewModel()
    }
}
