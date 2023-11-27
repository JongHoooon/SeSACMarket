//
//  DetailSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/15.
//

import UIKit

final class DetailSceneDIContainer {
    let product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    func makeDetailCoordinator(navigationController: UINavigationController) -> DefaultDetailCoordinator {
        return DefaultDetailCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension DetailSceneDIContainer: DetailCoordinatorDependencies {
    
    // MARK: - UseCase
    private func makeLikeUseCase() -> LikeUseCase {
        return DefaultLikeUseCase(productLocalRepository: makeProductLocalRepository())
    }
    
    // MARK: - Repository
    private func makeProductLocalRepository() -> ProductLocalRepository {
        return DefaultProductLocalRepository()
    }
    
    // MARK: - Detail View
    func makeDetailViewController(coordinator: DetailCoordinator) -> DetailViewController {
        return DetailViewController(reactor: makeDetailReactor(coordinator: coordinator))
    }
    
    private func makeDetailReactor(coordinator: DetailCoordinator) -> DetailReactor {
        return DetailReactor(
            product: product,
            likeUseCase: makeLikeUseCase(),
            coordinator: coordinator
        )
    }
}
