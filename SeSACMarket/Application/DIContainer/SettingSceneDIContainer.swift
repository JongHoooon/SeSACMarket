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
        return SettingViewController(viewModel: makeSettingViewModel(coordinator: coordinator))
    }
    
    private func makeSettingViewModel(coordinator: SettingCoordinator) -> SettingViewModel {
        return SettingViewModel(coordinator: coordinator)
    }
    
    // MARK: - Logout View
    func makeLogoutViewController(coordinator: SettingCoordinator) -> LogoutViewController {
        return LogoutViewController(viewModel: makeLogoutViewModel(coordinator: coordinator))
    }
    
    private func makeLogoutViewModel(coordinator: SettingCoordinator) -> LogoutViewModel {
        return LogoutViewModel(coordinator: coordinator)
    }
    
    // MARK: - Logout Alert
    func makeLogoutAlertController(confirmCompletion: @escaping () -> Void) -> UIAlertController {
        let logoutAlertController = UIAlertController(
            title: nil,
            message: "정말로 로그아웃 하시겠습니까??",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        let confirmAction = UIAlertAction(
            title: "로그아웃",
            style: .destructive,
            handler: { _ in
                confirmCompletion()
        })
        [
            cancelAction,
            confirmAction
        ].forEach { logoutAlertController.addAction($0) }
        return logoutAlertController
    }
}
