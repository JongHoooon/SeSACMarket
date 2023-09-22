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
    func finish(child: CoordinatorProtocol)
    func showAuthScene()
}

final class TabBarCoordinator: CoordinatorProtocol,
                               ChangeRootableProtocol {

    var childCoordinators: [CoordinatorProtocol] = []
    weak var delegate: TabBarCoordinatorDelegate?
    private let dependencies: TabBarCoordinatorDependencies
    let navigationController: UINavigationController

    private let searchSceneNavigationController = TabBarEnum.search.configureTabBarItem(navigationController: UINavigationController())
    private let favoriteSceneNavigationController = TabBarEnum.favorite.configureTabBarItem(navigationController: UINavigationController())
    
    // MARK: - Init
    init(
        dependencies: TabBarCoordinatorDependencies,
        navigationController: UINavigationController
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
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
        navigationController.pushViewController(tabBarController, animated: false)
        startSearchScene(navigationController: searchSceneNavigationController)
        startFavoriteScene(navigationController: favoriteSceneNavigationController)
    }
    
    func finish() {
        searchSceneNavigationController.viewControllers.removeAll()
        favoriteSceneNavigationController.viewControllers.removeAll()
        childCoordinators.removeAll()
        guard let delegate
        else {
            fatalError("TabBarCoordinatorDelegate is not linked")
        }
        delegate.finish(child: self)
    }
}

extension TabBarCoordinator: SearchCoordinatorDelegate {
    
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
        flow.delegate = self
        flow.start()
        addChildCoordinator(child: flow)
    }
    func startFavoriteScene(navigationController: UINavigationController) {
        let favoriteSceneDIContainer = dependencies.makeFavoriteSceneDIContainer()
        let flow = favoriteSceneDIContainer.makeFavoriteSceneCoordinator(navigationController: navigationController)
        flow.delegate = self
        flow.start()
        addChildCoordinator(child: flow)
    }
}

