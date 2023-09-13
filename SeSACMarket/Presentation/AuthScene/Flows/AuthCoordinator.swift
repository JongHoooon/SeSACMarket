//
//  AuthCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol AuthCoordinatorDependencies {
    func makeLoginViewController(actions: LoginViewModelActions) -> LoginViewController
}

protocol AuthCoordinatorDelegate: AnyObject {
    func showTabBarScene()
}

final class AuthCoordinator: CoordinatorProtocol,
                             ChangeRootableProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    private let dependencies: AuthCoordinatorDependencies
    weak var delegate: AuthCoordinatorDelegate?
    var navigationController = UINavigationController()
    let type: CoordinatorType = .auth
    
    init(
        dependencies: AuthCoordinatorDependencies
    ) {
        self.dependencies = dependencies
    }
    
    func start() {
        guard let delegate
        else { fatalError("AuthCoordinatorDelegate in not linked") }
        let actions = LoginViewModelActions(showTabBar: delegate.showTabBarScene)
        let vc = dependencies.makeLoginViewController(actions: actions)
        let nav = UINavigationController(rootViewController: vc)
        changeWindowRoot(rootViewController: nav)
    }
}
