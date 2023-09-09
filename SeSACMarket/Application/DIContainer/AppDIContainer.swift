//
//  AppDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import Foundation

final class AppDIContainer {
    
    // MARK: - Network
    lazy var apiDataTransferService = DefaultAPIDataTransferService()
    
    // MARK: - DIContainer of Scene
    func makeAuthSceneDIContainer() -> AuthSceneDIContainer {
        return AuthSceneDIContainer()
    }
    
    func makeTabBarSceneDIContainer() -> TabBarSceneDIContainer {
        let dependencies = TabBarSceneDIContainer.Dependencies(apiDataTransferService: apiDataTransferService)
        return TabBarSceneDIContainer(dedepdencies: dependencies)
    }
}
