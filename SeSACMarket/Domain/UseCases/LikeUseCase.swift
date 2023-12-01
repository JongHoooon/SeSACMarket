//
//  LikeUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/14.
//

import Foundation

import RxSwift

protocol LikeUseCase {
    func isLikeProduct(id: String) -> Single<Bool>
    func toggleProductLike(product: Product, current: Bool) -> Single<Bool>
}

final class DefaultLikeUseCase: LikeUseCase {
    
    // MARK: - Properties
    private let productLocalRepository: ProductLocalRepository
    private let disposeBag: DisposeBag
    
    init(productLocalRepository: ProductLocalRepository) {
        self.productLocalRepository = productLocalRepository
        self.disposeBag = DisposeBag()
    }
    
    func toggleProductLike(product: Product, current: Bool) -> Single<Bool> {
        switch current {
        case true:
            return productLocalRepository.deleteLikeProduct(id: product.id)
                .map { _ in !current }
                .do(onSuccess: { [weak self] _ in
                    self?.postProductSelectedNotification(id: product.id, selected: !current)
                })
            
        case false:
            return productLocalRepository.saveLikeProduct(product: product)
                .map { _ in !current }
                .do(onSuccess: { [weak self] _ in
                    self?.postProductSelectedNotification(id: product.id, selected: !current)
                })
        }
    }
    
    func isLikeProduct(id: String) -> Single<Bool> {
        return productLocalRepository.isLikeProduct(id: id)
    }
}

private extension LikeUseCase {
    func postProductSelectedNotification(id: String, selected: Bool) {
        NotificationCenter.default.post(
            name: .likeProduct,
            object: nil,
            userInfo: [
                "id": id,
                "isSelected": selected
            ]
        )
    }
}
