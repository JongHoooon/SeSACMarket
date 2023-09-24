//
//  SettingSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

final class SettingSceneDIContainer {

    func makeSettingSceneCoordinator(navigationController: UINavigationController) -> DefaultSettingCoordinator {
        return DefaultSettingCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension SettingSceneDIContainer: SettingCoordinatorDependencies {
    
    // MARK: - Setting View
    func makeSettingViewController(coordinator: SettingCoordinator) -> SettingViewController {
        return SettingViewController(viewModel: makeSettingViewMode(coordinator: coordinator))
    }
    
    private func makeSettingViewMode(coordinator: SettingCoordinator) -> SettingViewModel {
        return SettingViewModel(coordinator: coordinator)
    }
    
    // MARK: - Logout View
    func makeLogoutViewController(coordinator: SettingCoordinator) -> LogoutViewController {
        return LogoutViewController(viewModel: makeLogoutViewModel(coordinator: coordinator))
    }
    
    private func makeLogoutViewModel(coordinator: SettingCoordinator) -> LogoutViewModel {
        return LogoutViewModel(coordinator: coordinator)
    }

}
