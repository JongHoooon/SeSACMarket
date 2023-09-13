//
//  LogoutCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

protocol LogoutCoordinatorDependencies {
}

protocol LogoutCoordinatorDelegate: AnyObject {
}

final class LogoutCoordinator: CoordinatorProtocol {

    private let dependencies: LogoutCoordinatorDependencies
    weak var delegate: LogoutCoordinatorDelegate?
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var type: CoordinatorType  = .setting
    
    init(
        dependencies: LogoutCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    func start() {}
}
