//
//  FavoriteSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

final class FavoriteSceneDIContainer {
    
    func makeFavoriteSceneCoordinator(navigationController: UINavigationController) -> DefaultFavoriteCoordinator {
        return DefaultFavoriteCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
}
 
extension FavoriteSceneDIContainer: FavoriteCoordinatorDependencies {
    
    // MARK: - Use Cases
    private func makeFavoriteUseCase() -> FavoriteUseCase {
        return DefaultFavoriteUseCase(productLocalRepository: makeLocalRepository())
    }
    
    private func makeLikeUseCase() -> LikeUseCase {
        return DefaultLikeUseCase(productLocalRepository: DefaultProductLocalRepository())
    }
    
    // MARK: - Repository
    private func makeLocalRepository() -> ProductLocalRepository {
        return DefaultProductLocalRepository()
    }
    
    // MARK: - Favorite Scene
    func makeFavoriteViewController(coordinator: FavoriteCoordinator) -> FavoriteViewController {
        return FavoriteViewController(reactor: makeFavoriteReactor(coordinator: coordinator))
    }
    
    private func makeFavoriteReactor(coordinator: FavoriteCoordinator) -> FavoriteReactor {
        return FavoriteReactor(
            productLocalUseCase: makeFavoriteUseCase(),
            likeUseCase: makeLikeUseCase(),
            coordinator: coordinator
        )
    }
}
