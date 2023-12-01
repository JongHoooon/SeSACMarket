//
//  SearchUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxSwift
import RxRelay

protocol SearchUseCase {
    func fetchProducts(productsQuery: ProductQuery, start: Int) -> Single<ProductsPage>
}

final class DefaultSearchUseCase: SearchUseCase {
    
    private let productRemoteRepository: ProductRemoteRepository
    private let productLocalRepository: ProductLocalRepository
    
    init(
        productRemoteRepository: ProductRemoteRepository,
        productLocalRepository: ProductLocalRepository
    ) {
        self.productRemoteRepository = productRemoteRepository
        self.productLocalRepository = productLocalRepository
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
        .flatMap { [weak self] productsPage in
            guard let self else { return .never() }
            return self.checkIsLike(productsPage: productsPage)
        }
    }
}

private extension DefaultSearchUseCase {
    func checkIsLike(productsPage: ProductsPage) -> Single<ProductsPage> {
        var productsPage = productsPage
        let products = productsPage.items
        let isLikes = products.map { productLocalRepository.isLikeProduct(id: $0.id) }
        let result = Single.zip(isLikes)
            .map { isLikes -> [Product] in
                return zip(products, isLikes)
                    .map { product, isLike in
                        var product = product
                        product.isLike = isLike
                        return product
                    }
            }
            .map {
                productsPage.items = $0
                return productsPage
            }
        return result
    }
}
