//
//  ProductRemoteRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxSwift

protocol ProductRemoteRepository {
    func fetchProducts(productQuery: ProductQuery, start: Int, display: Int) -> Single<[Product]>
}
