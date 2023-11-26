//
//  ProductRemoteFetchUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxRelay
import RxSwift

protocol ProductRemoteFetchUseCase {
    func fetchProducts(query: String, sort: Product.SortValue, start: Int, display: Int) async throws -> ProductsPage
    func fetchProducts(query: String, sort: Product.SortValue, start: Int, display: Int)
    var fetchProducts: PublishSubject<[Product]> { get }
    
//    func fetchProducts(productsQuery: ProductQuery, start: Int, display: Int) -> Single<Result<ProductsPage, Error>>
    
    func fetchProducts(productsQuery: ProductQuery, start: Int, display: Int) -> Single<ProductsPage>
}

final class DefaultProductRemoteFetchUseCase: ProductRemoteFetchUseCase {
    
    private let productRemoteRepository: ProductRemoteRepository
    var fetchProducts = PublishSubject<[Product]>()
    private let disposebag = DisposeBag()
    
    init(productRemoteRepository: ProductRemoteRepository) {
        self.productRemoteRepository = productRemoteRepository
    }
    
    /// - start: 검색 시작 페이지 위치(1이상 1000이하)
    /// - display: 한 번에 표시할 검색 결과 개수(default: 30개)
    func fetchProducts(
        query: String,
        sort: Product.SortValue,
        start: Int,
        display: Int = 30
    ) async throws -> ProductsPage {
        return try await productRemoteRepository.fetchProducts(
            query: query,
            sort: sort,
            start: start,
            display: display
        )
    }
    
    func fetchProducts(
        query: String,
        sort: Product.SortValue,
        start: Int,
        display: Int = 30
    ) {
        productRemoteRepository.fetchProducts(
            query: query,
            sort: sort,
            start: start,
            display: display
        )
        .subscribe(
            with: self,
            onSuccess: { owner, productPage in
                owner.fetchProducts.onNext(productPage.items)
            },
            onFailure: { owner, error in
                owner.fetchProducts.onError(error)
        })
        .disposed(by: disposebag)
    }
    
    func fetchProducts(
        productsQuery: ProductQuery,
        start: Int,
        display: Int
    ) -> Single<Result<ProductsPage, Error>> {
        .create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            self.productRemoteRepository.fetchProducts(
                productQuery: productsQuery,
                start: start,
                display: display
            )
            .subscribe(
                onSuccess: {
                    single(.success(.success($0)))
                },
                onFailure: {
                    single(.success(.failure($0)))
                }
            )
            .disposed(by: self.disposebag)
            
            return Disposables.create()
        }
        
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
