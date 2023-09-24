//
//  TabBarCoordinator.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

protocol TabBarCoordinatorDependencies {
    func makeTabBarController() -> UITabBarController
    func makeSearchSceneDIContainer() -> SearchSceneDIContainer
    func makeFavoriteSceneDIContainer() -> FavoriteSceneDIContainer
}

protocol TabBarCoordinatorDelegate: AnyObject {
    func showAuthScene()
}

final class TabBarCoordinator: CoordinatorProtocol,
                               ChangeRootableProtocol {

    private let dependencies: TabBarCoordinatorDependencies
    weak var delegate: TabBarCoordinatorDelegate?
    weak var finishDelegate: CoordinatorFinishDelegate?
    let navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol]

    private let searchSceneNavigationController = TabBarEnum.search.configureTabBarItem(navigationController: UINavigationController())
    private let favoriteSceneNavigationController = TabBarEnum.favorite.configureTabBarItem(navigationController: UINavigationController())
    
    // MARK: - Init
    init(
        dependencies: TabBarCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
        self.childCoordinators = []
        print("init - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func start() {
        let tabBarController = dependencies.makeTabBarController()
        tabBarController.viewControllers = [
            searchSceneNavigationController,
            favoriteSceneNavigationController
        ]
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeInEaseOut
        )
        navigationController.view.window?.layer.add(transition, forKey: kCATransition)
        navigationController.viewControllers = [tabBarController]
        startSearchScene(navigationController: searchSceneNavigationController)
        startFavoriteScene(navigationController: favoriteSceneNavigationController)
    }
}

extension TabBarCoordinator: FavoriteCoordinatorDelegate {
    func showAuth() {
        guard let delegate
        else {
            fatalError("TabBarCoordinatorDelegate is not linked")
        }
        finish()
        delegate.showAuthScene()
    }
}

private extension TabBarCoordinator {
    func startSearchScene(navigationController: UINavigationController) {
        let searchSceneDIContainer = dependencies.makeSearchSceneDIContainer()
        let flow = searchSceneDIContainer.makeSearchSceneCoordinator(navigationController: navigationController)
        flow.finishDelegate = self
        flow.start()
        addChildCoordinator(child: flow)
    }
    func startFavoriteScene(navigationController: UINavigationController) {
        let favoriteSceneDIContainer = dependencies.makeFavoriteSceneDIContainer()
        let flow = favoriteSceneDIContainer.makeFavoriteSceneCoordinator(navigationController: navigationController)
        flow.delegate = self
        flow.finishDelegate = self
        flow.start()
        addChildCoordinator(child: flow)
    }
}

extension TabBarCoordinator: CoordinatorFinishDelegate {}
