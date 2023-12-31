//
//  SearchSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class SearchSceneDIContainer {

    func makeSearchSceneCoordinator(navigationController: UINavigationController) -> DefaultSearchCoordinator {
        return DefaultSearchCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension SearchSceneDIContainer: SearchCoordinatorDependencies {
    
    // MARK: - Use Cases
    private func makeSearchUseCase() -> SearchUseCase {
        return DefaultSearchUseCase(
            productRemoteRepository: makeProductRemoteRepository(), 
            productLocalRepository: makeProductLocalRepository()
        )
    }
    
    private func makeLikeUseCase() -> LikeUseCase {
        return DefaultLikeUseCase(productLocalRepository: makeProductLocalRepository())
    }
    
    // MARK: - Repositories
    private func makeProductLocalRepository() -> ProductLocalRepository {
        return DefaultProductLocalRepository()
    }
    
    private func makeProductRemoteRepository() -> ProductRemoteRepository {
        return DefaultProductRemoteRepository()
    }
    
    // MARK: - Search View
    func makeSearchViewController(coordinator: SearchCoordinator) -> SearchViewController {
        return SearchViewController(reactor: makeSearchReactor(coordinator: coordinator))
    }
    
    private func makeSearchReactor(coordinator: SearchCoordinator) -> SearchReactor {
        return SearchReactor(
            searchUseCase: makeSearchUseCase(),
            likeUseCase: makeLikeUseCase(),
            coordinator: coordinator
        )
    }
}
