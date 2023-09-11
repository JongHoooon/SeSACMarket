//
//  DetailCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import UIKit

protocol DetailCoordinatorDependencies {
}

protocol DetailCoordinatorDelegate: AnyObject {
    
}

final class DetailCoordinator: CoordinatorProtocol {
    weak var delegate: DetailCoordinatorDelegate?
    private let dependencies: DetailCoordinatorDependencies
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var type: CoordinatorType = .detail
    
    init(
        navigationController: UINavigationController,
         dependencies: DetailCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {}
}
