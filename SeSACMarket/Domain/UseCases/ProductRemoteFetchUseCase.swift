//
//  ProductRemoteFetchUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxSwift

protocol ProductRemoteFetchUseCase {
    func fetchProducts(productsQuery: ProductQuery, start: Int, display: Int) -> Single<ProductsPage>
    func fetchProducts(productsQuery: ProductQuery) -> Single<[Product]>
}

final class DefaultProductRemoteFetchUseCase: ProductRemoteFetchUseCase {
    
    private let productRemoteRepository: ProductRemoteRepository
    private var productsPage: ProductsPage
    
    init(productRemoteRepository: ProductRemoteRepository) {
        self.productRemoteRepository = productRemoteRepository
        self.productsPage = ProductsPage(start: 0, display: 30, items: [])
    }
    
    func fetchProducts(productsQuery: ProductQuery) -> Single<[Product]> {
        return productRemoteRepository.fetchProducts(
            productQuery: productsQuery,
            start: 0,
            display: 30
        )
        .map { $0.items }
    }
    
    func fetchProducts(
        productsQuery: ProductQuery,
        start: Int,
        display: Int
    ) -> Single<ProductsPage> {
        return productRemoteRepository.fetchProducts(
            productQuery: productsQuery,
            start: start,
            display: display
        )
    }
}
