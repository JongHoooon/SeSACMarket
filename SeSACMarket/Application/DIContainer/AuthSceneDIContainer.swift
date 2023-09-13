//
//  AuthSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class AuthSceneDIContainer {
    func makeAuthCoordinator() -> AuthCoordinator {
        return AuthCoordinator(
            dependencies: self
        )
    }
}

extension AuthSceneDIContainer: AuthCoordinatorDependencies {
    func makeLoginViewController(actions: LoginViewModelActions) -> LoginViewController {
        return LoginViewController(viewModel: makeLoginViewModel(actions: actions))
    }
    
    func makeLoginViewModel(actions: LoginViewModelActions) -> LoginViewModel {
        return LoginViewModel(actions: actions)
    }
}
