//
//  FavoriteUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

import RxSwift

protocol FavoriteUseCase {
    func fetchAllLikeProducts() -> Single<[Product]>
    func fetchQueryLikeProducts(query: String) -> Single<[Product]>
}

final class DefaultFavoriteUseCase: FavoriteUseCase {
    
    private let productLocalRepository: ProductLocalRepository
    
    init(productLocalRepository: ProductLocalRepository) {
        self.productLocalRepository = productLocalRepository
    }
    
    func fetchAllLikeProducts() -> Single<[Product]> {
        return productLocalRepository.fetchAllLikeProducts()
    }
    
    func fetchQueryLikeProducts(query: String) -> Single<[Product]> {
        return productLocalRepository.fetchQueryLikeProducts(query: query)
    }
}
