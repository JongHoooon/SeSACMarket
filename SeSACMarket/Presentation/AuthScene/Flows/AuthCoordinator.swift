//
//  AuthCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol AuthCoordinatorDependencies {
    func makeLoginViewController() -> LoginViewController
}

protocol AuthCoordinatorDelegate: AnyObject {
    func showTabBar()
}

final class AuthCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    private let dependencies: AuthCoordinatorDependencies
    weak var delegate: AuthCoordinatorDelegate?
    
    init(
        dependencies: AuthCoordinatorDependencies
    ) {
        self.dependencies = dependencies
    }
    
    func start() {
        let vc = dependencies.makeLoginViewController()
        let nav = UINavigationController(rootViewController: vc)
        changeWindowRoot(rootViewController: nav)
    }
}