//
//  CoordinatorProtocol.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get }
    var type: CoordinatorType { get }
    func start()
}

// child 관리
extension CoordinatorProtocol {
    func addChildCoordinator(child: CoordinatorProtocol) {
        childCoordinators.append(child)
    }
    
    func removeChildCoordinator(child: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter { $0.type != child.type }
        child.navigationController.popToRootViewController(animated: false)
    }
}

protocol ChangeRootableProtocol {}
extension ChangeRootableProtocol {
    func changeWindowRoot(rootViewController: UIViewController, duration: TimeInterval = 1.0) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController = rootViewController
        sceneDelegate?.window?.makeKeyAndVisible()
        
        guard let window = sceneDelegate?.window else { return }
        
        UIView.transition(
            with: window,
            duration: duration,
            options: [.transitionCrossDissolve],
            animations: nil,
            completion: nil
        )
    }
}
