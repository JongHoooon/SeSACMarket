//
//  CoordinatorFinishDelegate.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/24.
//

import Foundation

protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(child: CoordinatorProtocol)
}

extension CoordinatorFinishDelegate where Self: CoordinatorProtocol {
    func coordinatorDidFinish(child: CoordinatorProtocol) {
        child.navigationController.viewControllers.removeAll()
        self.removeChildCoordinator(child: child)
    }
}

