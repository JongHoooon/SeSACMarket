//
//  AppFlowCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class AppFlowCoordinator: CoordinatorProtocol {
    
    private let appDIContainer: AppDIContainer
    var childCoordinators: [CoordinatorProtocol] = []
    let navigationController: UINavigationController
    
    init(
        appDIContainer: AppDIContainer,
        navigationController: UINavigationController
    ) {
        self.appDIContainer = appDIContainer
        self.navigationController = navigationController
        print("Init - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func start() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: UserDefaultsKey.isLoggedIn.key)
        print("isLoggedIn - \(isLoggedIn)")
        switch isLoggedIn {
        case true:      showTabBarScene()
        case false:     showAuthScene()
        }
    }
    
    func finish() {}
    
    func finish(child: CoordinatorProtocol) {
        navigationController.viewControllers.removeAll()
        removeChildCoordinator(child: child)
    }
}

extension AppFlowCoordinator: TabBarCoordinatorDelegate {
    func showAuthScene() {
        let authSceneDIContainer = appDIContainer.makeAuthSceneDIContainer()
        let flow = authSceneDIContainer.makeAuthCoordinator(navigationController: navigationController)
        flow.delegate = self
        addChildCoordinator(child: flow)
        navigationController.isNavigationBarHidden = false
        flow.start()
    }
}

extension AppFlowCoordinator: AuthCoordinatorDelegate {
    func showTabBarScene() {
        let tabBarSceneDIContainer = appDIContainer.makeTabBarSceneDIContainer()
        let flow = tabBarSceneDIContainer.makeTabBarFlowCoordinator(navigationController: navigationController)
        flow.delegate = self
        addChildCoordinator(child: flow)
        navigationController.isNavigationBarHidden = true
        flow.start()
    }
}

