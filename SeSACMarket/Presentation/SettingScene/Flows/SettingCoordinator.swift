//
//  SettingCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

protocol SettingCoordinatorDependencies {
    func makeSettingViewController(coordinator: SettingCoordinator) -> SettingViewController
    func makeLogoutViewController(coordinator: LogoutCoordinator) -> LogoutViewController
}

protocol SettingCoordinatorDelegate: AnyObject {
    func showAuth()
    func finish(child: CoordinatorProtocol)
}

protocol SettingDismiss {
    func dismiss()
    func finish()
}

protocol SettingCoordinator: AnyObject, SettingDismiss {
    func showLogout()
}

protocol LogoutCoordinator: AnyObject, SettingDismiss {
    func showAuth()
}

final class DefaultSettingCoordinator: CoordinatorProtocol {

    private let dependencies: SettingCoordinatorDependencies
    weak var delegate: SettingCoordinatorDelegate?
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    private let settingNavigationViewController = UINavigationController()
    
    init(
        dependencies: SettingCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func start() {
        let vc = dependencies.makeSettingViewController(coordinator: self)
        settingNavigationViewController.pushViewController(vc, animated: false)
        settingNavigationViewController.modalPresentationStyle = .fullScreen
        navigationController.present(settingNavigationViewController, animated: true)
    }
    
    func finish() {
        guard let delegate
        else {
            fatalError("SettingCoordinatorDelegate is not linked")
        }
        childCoordinators.removeAll()
        settingNavigationViewController.viewControllers.removeAll()
        delegate.finish(child: self)
    }
    
    func dismiss() {
        settingNavigationViewController.dismiss(animated: true)
        finish()
    }
}

extension DefaultSettingCoordinator: SettingCoordinator {
    func showLogout() {
        let vc = dependencies.makeLogoutViewController(coordinator: self)
        settingNavigationViewController.pushViewController(vc, animated: true)
    }
}

extension DefaultSettingCoordinator: LogoutCoordinator {
    func showAuth() {
        guard let delegate = delegate
        else {
            fatalError("SettingCoordinatorDelegate is not linked")
        }
        delegate.finish(child: self)
        settingNavigationViewController.viewControllers.removeAll()
        settingNavigationViewController.dismiss(animated: false)
        childCoordinators.removeAll()
        delegate.showAuth()
    }
}
