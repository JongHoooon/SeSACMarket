//
//  DefaultSearchCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol SearchCoordinatorDependencies {
    func makeSearchViewController(coordinator: SearchCoordinator) -> SearchViewController
}

protocol SearchCoordinator: AnyObject, ErrorAlertable {
    func pushToDetail(product: Product)
}

final class DefaultSearchCoordinator: CoordinatorProtocol {
    
    private let dependencies: SearchCoordinatorDependencies
    weak var finishDelegate: CoordinatorFinishDelegate?
    let navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol]
    
    init(
        dependencies: SearchCoordinatorDependencies,
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
        let vc = dependencies.makeSearchViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: false)
    }
}

extension DefaultSearchCoordinator: SearchCoordinator, DetailCoordinatorable {}

extension DefaultSearchCoordinator: CoordinatorFinishDelegate {}
