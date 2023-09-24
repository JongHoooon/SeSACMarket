//
//  DetailCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/15.
//

import UIKit

protocol DetailCoordinatorDependencies {
    var product: Product { get }
    func makeDetailViewController(coordinator: DetailCoordinator) -> DetailViewController
}

protocol DetailCoordinator: AnyObject, ErrorAlertable {
    func finish()
}

final class DefaultDetailCoordinator: CoordinatorProtocol,
                                      ChangeRootableProtocol {
    
    private let dependencies: DetailCoordinatorDependencies
    weak var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol]
    
    init(
        dependencies: DetailCoordinatorDependencies,
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
        let vc = dependencies.makeDetailViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension DefaultDetailCoordinator: DetailCoordinator {}
