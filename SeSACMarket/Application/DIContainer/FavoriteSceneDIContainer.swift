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
    
    // MARK: - Favorite Scene
    func makeFavoriteViewController(actions: FavoriteViewModelActions) -> FavoriteViewController {
        return FavoriteViewController(viewModel: makeFavoriteViewModel(actions: actions))
    }
    
    private func makeFavoriteViewModel(actions: FavoriteViewModelActions) -> FavoriteViewModel {
        return FavoriteViewModel(productLocalUseCase: makeProductLocalUseCase(), actions: actions)
    }
    
    // MARK: - Detail Scene
    func makeDetailViewController(product: Product) -> DetailViewController {
        return DetailViewController(viewModel: makeDetailViewModel(product: product))
    }
    
    func makeDetailViewModel(product: Product) -> DetailViewModel {
        return DetailViewModel(product: product, productLocalUseCase: makeProductLocalUseCase())
    }
}
