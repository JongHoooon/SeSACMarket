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

protocol SearchCoordinatorDelegate: AnyObject {
    
}

protocol SearchCoordinator: AnyObject {
    func pushToDetail(product: Product)
}

final class DefaultSearchCoordinator: CoordinatorProtocol {
    
    var childCoordinators: [CoordinatorProtocol] = []
    weak var delegate: SearchCoordinatorDelegate?
    weak var finishDelegate: CoordinatorFinishDelegate?
    private let dependencies: SearchCoordinatorDependencies
    let navigationController: UINavigationController
    
    init(
        dependencies: SearchCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func start() {
        let vc = dependencies.makeSearchViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: false)
    }
}

extension DefaultSearchCoordinator: SearchCoordinator {
    func pushToDetail(product: Product) {
        let detailSceneDIContainer = DetailSceneDIContainer(product: product)
        let flow = detailSceneDIContainer.makeDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(child: flow)
        flow.finishDelegate = self
        flow.start()
    }
}

extension DefaultSearchCoordinator: CoordinatorFinishDelegate {}
