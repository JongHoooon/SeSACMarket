//
//  ProductLocalFetchUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

final class ProductLocalFetchUseCase {
    
    private let productLocalRepository: ProductLocalRepository
    
    init(productLocalRepository: ProductLocalRepository) {
        self.productLocalRepository = productLocalRepository
    }
    
    func fetchAllLikeProducts() async -> [Product] {
//        await productLocalRepository.fetchAllLikeProducts()
        return []
    }
    
    func fetchQueryLikeProducts(query: String) async -> [Product] {
        await productLocalRepository.fetchQueryLikeProducts(query: query)
        return []
    }
}
