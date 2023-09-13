//
//  SettingCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

protocol SettingCoordinatorDependencies {
}

protocol SettingCoordinatorDelegate: AnyObject {
}

final class SettingCoordinator: CoordinatorProtocol {

    private let dependencies: SettingCoordinatorDependencies
    weak var delegate: SettingCoordinatorDelegate?
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var type: CoordinatorType  = .setting
    
    init(
        dependencies: SettingCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    func start() {}
}
