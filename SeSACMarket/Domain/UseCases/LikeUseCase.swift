//
//  LikeUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/14.
//

import Foundation

import RxSwift

protocol LikeUseCase {
    func saveLikeProduct(product: Product) async throws
    func deleteLikeProduct(productID: String) async throws
    func isLikeProduct(productID: String) async -> Bool
    func toggleProductLike(product: Product, current: Bool) -> Single<Bool>
}

final class DefaultLikeUseCase: LikeUseCase {
    
    // MARK: - Repository
    private let productLocalRepository: ProductLocalRepository
    
    init(productLocalRepository: ProductLocalRepository) {
        self.productLocalRepository = productLocalRepository
    }
    
    func toggleProductLike(product: Product, current: Bool) -> Single<Bool> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            switch current {
            case true:
                Task {
                    do {
                        try await self.productLocalRepository.deleteLikeProduct(productID: product.id)
                        single(.success(false))
                    } catch {
                        single(.failure(error))
                    }
                }
                
            case false:
                Task {
                    do {
                        try await self.productLocalRepository.saveLikeProduct(product: product)
                        single(.success(true))
                    } catch {
                        single(.failure(error))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func saveLikeProduct(product: Product) async throws {
        try await productLocalRepository.saveLikeProduct(product: product)
        NotificationCenter.default.post(
            name: .likeProduct,
            object: nil,
            userInfo: [
                "id": product.id,
                "isSelected": true
            ]
        )
    }
    
    func deleteLikeProduct(productID: String) async throws {
        try await productLocalRepository.deleteLikeProduct(productID: productID)
        NotificationCenter.default.post(
            name: .likeProduct,
            object: nil,
            userInfo: [
                "id": productID,
                "isSelected": false
            ]
        )
    }
    
    func isLikeProduct(productID: String) async -> Bool {
        await productLocalRepository.isLikeProduct(productID: productID)
    }
}
