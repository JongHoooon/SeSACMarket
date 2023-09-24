//
//  ProductRemoteFetchUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxRelay
import RxSwift

protocol ProductRemoteFetchUseCase {
    func fetchProducts(query: String, sort: SortEnum, start: Int, display: Int) async throws -> ProductsPage
    func fetchProducts(query: String, sort: SortEnum, start: Int, display: Int)
    var fetchProducts: PublishSubject<[Product]> { get }
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
        sort: SortEnum,
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
        sort: SortEnum,
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
            onNext: { owner, productPage in
                owner.fetchProducts.onNext(productPage.items)
            },
            onError: { owner, error in
                owner.fetchProducts.onError(error)
        })
        .disposed(by: disposebag)
    }
}
