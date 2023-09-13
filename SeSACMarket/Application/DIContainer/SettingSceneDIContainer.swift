//
//  SettingSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

final class SettingSceneDIContainer {

    struct Dependendcies {

    }
    
    private let dependencies: Dependendcies
    
    init(dependcencies: Dependendcies) {
        self.dependencies = dependcencies
    }
    
    func makeSettingSceneCoordinator(navigationController: UINavigationController) -> SettingCoordinator {
        return SettingCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension SettingSceneDIContainer: SettingCoordinatorDependencies {
}
