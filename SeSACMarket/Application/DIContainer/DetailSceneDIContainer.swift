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
        return DetailViewController(viewModel: makeDetailViewModel(coordinator: coordinator))
    }
    
    private func makeDetailViewModel(coordinator: DetailCoordinator) -> DetailViewModel {
        return DetailViewModel(
            product: product,
            likeUseCase: makeLikeUseCase(),
            coordinator: coordinator
        )
    }
}
