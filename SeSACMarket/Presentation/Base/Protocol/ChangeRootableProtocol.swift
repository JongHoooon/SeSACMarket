//
//  ChangeRootableProtocol.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/24.
//

import UIKit

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
