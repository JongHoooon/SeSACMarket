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
    
    private func makeDetailViewModel(product: Product) -> DetailViewModel {
        return DetailViewModel(product: product, productLocalUseCase: makeProductLocalUseCase())
    }
    
    // MARK: - Setting Scene
    func makeSettingViewController(actions: SettingViewModelActions) -> SettingViewController {
        return SettingViewController(viewModel: makeSettingViewModel(actions: actions))
    }
    
    private func makeSettingViewModel(actions: SettingViewModelActions) -> SettingViewModel {
        return SettingViewModel(actions: actions)
    }
    
    // MARK: - Logout Scene
    func makeLogoutViewController(actions: LogoutViewModelActions) -> LogoutViewController {
        return LogoutViewController(viewModel: makeLogoutViewModel(actions: actions))
    }
    
    private func makeLogoutViewModel(actions: LogoutViewModelActions) -> LogoutViewModel {
        return LogoutViewModel(actions: actions)
    }
}
