//
//  LogoutSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

final class LogoutSceneDIContainer {

    struct Dependendcies {

    }
    
    private let dependencies: Dependendcies
    
    init(dependcencies: Dependendcies) {
        self.dependencies = dependcencies
    }
    
    func makeSettingSceneCoordinator(navigationController: UINavigationController) -> LogoutCoordinator {
        return LogoutCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension LogoutSceneDIContainer: LogoutCoordinatorDependencies {
}
