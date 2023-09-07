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
    let navigationController = UINavigationController()
    let type = CoordinatorType.app
 
    init(
        appDIContainer: AppDIContainer
    ) {
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        #warning("삭제 필요!!!!")
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.isLoggedIn.key)
        let isLoggedIn = UserDefaults.standard.bool(forKey: UserDefaultsKey.isLoggedIn.key)
        
        switch isLoggedIn {
        case true:      showTabBarScene()
        case false:     showAuthScene()
        }
    }
}

extension AppFlowCoordinator: TabBarCoordinatorDelegate {
    func showAuthScene() {
        let authSceneDIContainer = appDIContainer.makeAuthSceneDIContainer()
        let flow = authSceneDIContainer.makeAuthCoordinator()
        flow.delegate = self
        childCoordinators = [flow]
        flow.start()
    }
}

extension AppFlowCoordinator: AuthCoordinatorDelegate {
    func showTabBarScene() {
        let tabBarSceneDIContainer = TabBarSceneDIContainer()
        let flow = tabBarSceneDIContainer.makeTabBarFlowCoordinator()
        flow.delegate = self
        childCoordinators = [flow]
        flow.start()
    }
}

