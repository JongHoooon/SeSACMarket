//
//  DefaultProductRemoteRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

import RxSwift

final class DefaultProductRemoteRepository: ProductRemoteRepository, APIDataTransferService {
    func fetchProducts(
        productQuery: ProductQuery,
        start: Int,
        display: Int
    ) -> Single<[Product]> {
        return Single<[Product]>.create { single in
            Task {
                do {
                    let productPageDTO = try await self.callRequest(
                        of: ProductsPageDTO.self,
                        api: ProductAPI.fetchQuery(
                            productQuery: productQuery,
                            start: start,
                            display: display
                        )
                    )
                    let products = productPageDTO.items.map { $0.toDomain() }
                    single(.success(products))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
