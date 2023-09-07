//
//  SearchSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

struct SearchSceneDIContainer {
    func makeSearchSceneDIContainer(navigationController: UINavigationController) -> SearchCoordinator {
        return SearchCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension SearchSceneDIContainer: SearchCoordinatorDependencies {
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController()
    }
}
