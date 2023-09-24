//
//  AuthCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol AuthCoordinatorDependencies {
    func makeLoginViewController(coordinator: AuthCoordinator) -> LoginViewController
}

protocol AuthCoordinatorDelegate: AnyObject {
    func showTabBarScene()
}

protocol AuthCoordinator: AnyObject {
    func showTabBar()
}

final class DefaultAuthCoordinator: CoordinatorProtocol,
                                    ChangeRootableProtocol {
    
    private let dependencies: AuthCoordinatorDependencies
    weak var delegate: AuthCoordinatorDelegate?
    weak var finishDelegate: CoordinatorFinishDelegate?
    let navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol]
    
    init(
        dependencies: AuthCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
        self.childCoordinators = []
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func start() {
        let vc = dependencies.makeLoginViewController(coordinator: self)
        navigationController.viewControllers = [vc]
        changeWindowRoot(rootViewController: navigationController)
    }
}

extension DefaultAuthCoordinator: AuthCoordinator {
    func showTabBar() {
        guard let delegate
        else {
            fatalError("AuthCoordinatorDelegate in not linked")
        }
        finish()
        delegate.showTabBarScene()
    }
}
