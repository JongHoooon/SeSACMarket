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
    }
    
    private let dependencies: Dependencies
    
    init(dedepdencies: Dependencies) {
        self.dependencies = dedepdencies
    }
    

}

extension SearchSceneDIContainer: SearchCoordinatorDependencies {
    
    // MARK: - Use Cases
    func makeProductRemoteUseCase() -> ProductRemoteUseCase {
        return ProductRemoteUseCase(
            productRemoteRepository: makeProductRemoteRepository()
        )
    }
    
    // MARK: - Repositories
    func makeProductRemoteRepository() -> ProductRemoteRepository {
        return DefaultProductRemoteRepository(
            apiDataTransferManager: dependencies.apiDataTransferService
        )
    }
    
    // MARK: - Search Scene
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController(viewModel: makeSearchViewModel())
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return DefaultSearchViewModel(
            productRemoteRepositoryUseCase: makeProductRemoteUseCase(),
            actions: SearchViewModelActions()
        )
    }
    
    func makeSearchSceneDIContainer(navigationController: UINavigationController) -> SearchCoordinator {
        return SearchCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}
