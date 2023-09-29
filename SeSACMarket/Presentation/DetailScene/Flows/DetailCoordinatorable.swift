//
//  DetailCoordinatorable.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/30.
//

import Foundation

protocol DetailCoordinatorable {
    func pushToDetail(product: Product)
}

extension DetailCoordinatorable where Self: CoordinatorProtocol & CoordinatorFinishDelegate {
    func pushToDetail(product: Product) {
        let detailDIContainer = DetailSceneDIContainer(product: product)
        let flow = detailDIContainer.makeDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(child: flow)
        flow.finishDelegate = self
        flow.start()
    }
}
