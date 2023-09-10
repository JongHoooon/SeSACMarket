//
//  SearchSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class SearchSceneDIContainer {
    
    struct Dependencies {
        let apiDataTransferService: APIDataTransferService
        let productLocalRepository: ProductLocalRepository
    }
    
    private let dependencies: Dependencies
    
    init(dedepdencies: Dependencies) {
        self.dependencies = dedepdencies
    }
    
    func makeSearchSceneCoordinator(navigationController: UINavigationController) -> SearchCoordinator {
        return SearchCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension SearchSceneDIContainer: SearchCoordinatorDependencies {
    
    // MARK: - Use Cases
    private func makeProductLocalUseCase() -> ProductLocalUseCase {
        return ProductLocalUseCase(productLocalRepository: dependencies.productLocalRepository)
    }
    
    private func makeProductRemoteUseCase() -> ProductRemoteUseCase {
        return ProductRemoteUseCase(
            productRemoteRepository: makeProductRemoteRepository()
        )
    }
    
    // MARK: - Repositories
    private func makeProductRemoteRepository() -> ProductRemoteRepository {
        return DefaultProductRemoteRepository(
            apiDataTransferManager: dependencies.apiDataTransferService
        )
    }
    
    // MARK: - Search Scene
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController(
            viewModel: makeSearchViewModel()
        )
    }
    
    private func makeSearchViewModel() -> SearchViewModel {
        return DefaultSearchViewModel(
            productLocalUseCase: makeProductLocalUseCase(),
            productRemoteUseCase: makeProductRemoteUseCase(),
            actions: SearchViewModelActions()
        )
    }
}
