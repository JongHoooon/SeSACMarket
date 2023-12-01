//
//  SearchUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxSwift

protocol SearchUseCase {
    func fetchProducts(productsQuery: ProductQuery, start: Int) -> Single<ProductsPage>
}

final class DefaultSearchUseCase: SearchUseCase {
    
    private let productRemoteRepository: ProductRemoteRepository
    
    init(
        productRemoteRepository: ProductRemoteRepository
    ) {
        self.productRemoteRepository = productRemoteRepository
    }
    
    func fetchProducts(
        productsQuery: ProductQuery,
        start: Int
    ) -> Single<ProductsPage> {
        return productRemoteRepository.fetchProducts(
            productQuery: productsQuery,
            start: start,
            display: 30
        )
    }
}
