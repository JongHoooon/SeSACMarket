//
//  ProductCollectionViewCellViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import RxRelay

final class ProductCollectionViewCellViewModel {
    
    let prodcut: Product
    let productLocalUseCase: ProductLocalUseCase
    let errorHandler: PublishRelay<Error>
    let needReload: PublishRelay<Void>?
    
    init(
        prodcut: Product,
        productLocalUseCase: ProductLocalUseCase,
        errorHandler: PublishRelay<Error>,
        needReload: PublishRelay<Void>? = nil
    ) {
        self.prodcut = prodcut
        self.productLocalUseCase = productLocalUseCase
        self.errorHandler = errorHandler
        self.needReload = needReload
    }
}
