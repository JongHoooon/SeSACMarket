//
//  AppFlowCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class AppFlowCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    private let appDIContainer: AppDIContainer
    
    init(
        appDIContainer: AppDIContainer
    ) {
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: UserDefaultsKey.isLoggedIn.key)
        
        switch isLoggedIn {
        case true:      showTabBar()
        case false:     showAuthView()
        }
    }
}

extension AppFlowCoordinator {
    func showAuthView() {
        let authSceneDIContainer = appDIContainer.makeAuthSceneDIContainer()
        let flow = authSceneDIContainer.makeAuthCoordinator()
        flow.delegate = self
        flow.start()
    }
}

extension AppFlowCoordinator: AuthCoordinatorDelegate {
    func showTabBar() {
        
    }
}

