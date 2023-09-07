//
//  AuthSceneDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

struct AuthSceneDIContainer {
    func makeAuthCoordinator() -> AuthCoordinator {
        return AuthCoordinator(
            dependencies: self
        )
    }
}

extension AuthSceneDIContainer: AuthCoordinatorDependencies {
    func makeLoginViewController() -> LoginViewController {
        return LoginViewController()
    }   
}