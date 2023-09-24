//
//  CoordinatorProtocol.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol CoordinatorProtocol: AnyObject, ErrorAlertable {
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get }
    func start()
    func finish()
}

extension CoordinatorProtocol {
    func addChildCoordinator(child: CoordinatorProtocol) {
        childCoordinators.append(child)
    }
    
    func removeChildCoordinator(child: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter { $0.self !== child.self }
    }
    
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(child: self)
    }
}
