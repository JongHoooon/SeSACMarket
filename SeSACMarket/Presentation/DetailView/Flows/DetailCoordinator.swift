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

protocol DetailCoordinatorDelegate: AnyObject {
    func finish(child: CoordinatorProtocol)
}

protocol DetailCoordinator: AnyObject {
    func finish()
}

final class DefaultDetailCoordinator: CoordinatorProtocol,
                                      ChangeRootableProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    private let dependencies: DetailCoordinatorDependencies
    weak var delegate: DetailCoordinatorDelegate?
    var navigationController: UINavigationController
    
    init(
        dependencies: DetailCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func start() {
        let vc = dependencies.makeDetailViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension DefaultDetailCoordinator: DetailCoordinator {
    func finish() {
        guard let delegate 
        else {
            fatalError("DetailCoordinatorDelegate is not linked")
        }
        delegate.finish(child: self)
    }
}
