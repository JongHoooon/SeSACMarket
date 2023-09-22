//
//  AuthSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class AuthSceneDIContainer {
    
    func makeAuthCoordinator(navigationController: UINavigationController) -> DefaultAuthCoordinator {
        return DefaultAuthCoordinator(
            dependencies: self,
            navigationController: navigationController
        )
    }
}

extension AuthSceneDIContainer: AuthCoordinatorDependencies {
    
    // MARK: - Login View
    func makeLoginViewController(coordinator: AuthCoordinator) -> LoginViewController {
        return LoginViewController(viewModel: makeLoginViewModel(coordinator: coordinator))
    }
    
    private func makeLoginViewModel(coordinator: AuthCoordinator) -> LoginViewModel {
        return LoginViewModel(coordinator: coordinator)
    }
}
