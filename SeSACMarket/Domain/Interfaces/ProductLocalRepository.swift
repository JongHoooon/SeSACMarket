//
//  ProductLocalRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxSwift

protocol ProductLocalRepository {
    func saveLikeProduct(product: Product) -> Single<Product>
    func deleteLikeProduct(productID: String) -> Single<String>
    func fetchAllLikeProducts() -> Single<[Product]>
    func fetchQueryLikeProducts(query: String) -> Single<[Product]>
    func isLikeProduct(productID: String) -> Single<Bool>
}
