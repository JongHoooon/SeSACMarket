//
//  SearchUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxSwift
import RxRelay

protocol SearchUseCase {
    func fetchFirstPageProducts(productsQuery: ProductQuery) -> Single<[Product]>
    func fetchNextPageProducts() -> Single<[Product]>
    var isEndPage: Bool? { get }
    func fetchProducts(productsQuery: ProductQuery, start: Int) -> Single<ProductsPage>
}

final class DefaultSearchUseCase: SearchUseCase {
    
    private let productRemoteRepository: ProductRemoteRepository
    private let productLocalRepository: ProductLocalRepository
    
    private let defaultDisplayCount = 30
    private var currentPage: Int?
    var isEndPage: Bool?
    private var query: String?
    private var sortValue: Product.SortValue?
    
    init(
        productRemoteRepository: ProductRemoteRepository,
        productLocalRepository: ProductLocalRepository
    ) {
        self.productRemoteRepository = productRemoteRepository
        self.productLocalRepository = productLocalRepository
    }
    
    func fetchFirstPageProducts(productsQuery: ProductQuery) -> Single<[Product]> {
        return productRemoteRepository.fetchProducts(
            productQuery: productsQuery,
            start: 1,
            display: defaultDisplayCount
        )
        .flatMap { [weak self] in
            guard let self else { return .never() }
            return self.checkIsLike(products: $0.items)
        }
        .do(onSuccess: { [weak self] in
            guard let self else { return }
            self.isEndPage = $0.count < self.defaultDisplayCount
            self.query = productsQuery.query
            self.sortValue = productsQuery.sortValue
            self.currentPage = 1
        })
    }
    
    func fetchNextPageProducts() -> Single<[Product]> {
        guard let query, let sortValue, let currentPage else { return .just([]) }
        
        return productRemoteRepository.fetchProducts(
            productQuery: ProductQuery(query: query, sortValue: sortValue),
            start: currentPage + 1,
            display: defaultDisplayCount
        )
        .flatMap { [weak self] in
            guard let self else { return .never() }
            return self.checkIsLike(products: $0.items)
        }
        .do(onSuccess: { [weak self] in
            guard let self else { return }
            self.isEndPage = $0.count < self.defaultDisplayCount
            self.currentPage = currentPage + 1
        })
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
    
    func checkIsLike(products: [Product]) -> Single<[Product]> {
        let isLikes = products.map { productLocalRepository.isLikeProduct(id: $0.id) }
        return Single.zip(isLikes)
            .map { isLikes -> [Product] in
                return zip(products, isLikes)
                    .map { product, isLike in
                        var product = product
                        product.isLike = isLike
                        return product
                    }
            }
    }
    
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
