//
//  SettingCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

protocol SettingCoordinatorDependencies {
    func makeSettingViewController(coordinator: SettingCoordinator) -> SettingViewController
    func makeLogoutViewController(coordinator: SettingCoordinator) -> LogoutViewController
}

protocol SettingCoordinatorDelegate: AnyObject {
    func showAuth()
}

protocol SettingCoordinator: AnyObject {
    func pushToLogout()
    func dismiss()
    func presentLogoutAlert()
    func finish()
    func showAuth()
}

final class DefaultSettingCoordinator: CoordinatorProtocol {

    private let dependencies: SettingCoordinatorDependencies
    weak var delegate: SettingCoordinatorDelegate?
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol]
    
    init(
        dependencies: SettingCoordinatorDependencies,
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
        let vc = dependencies.makeSettingViewController(coordinator: self)
        navigationController.viewControllers = [vc]
    }
}

extension DefaultSettingCoordinator: SettingCoordinator {
    func pushToLogout() {
        let vc = dependencies.makeLogoutViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAuth() {
        guard let delegate = delegate
        else {
            fatalError("SettingCoordinatorDelegate is not linked")
        }
        navigationController.viewControllers.removeAll()
        navigationController.dismiss(animated: false)
        finish()
        delegate.showAuth()
    }
    
    func presentLogoutAlert() {
        let alertController = UIAlertController(
            title: nil,
            message: "정말로 로그아웃 하시겠습니까??",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        let confirmAction = UIAlertAction(
            title: "로그아웃",
            style: .destructive,
            handler: { [weak self] _ in
                self?.showAuth()
        })
        [
            cancelAction,
            confirmAction
        ].forEach { alertController.addAction($0) }
        navigationController.present(alertController, animated: true)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
}
