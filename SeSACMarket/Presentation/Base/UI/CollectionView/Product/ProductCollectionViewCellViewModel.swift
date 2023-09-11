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
    let needReload: PublishRelay<Void>?
    
    init(
        prodcut: Product,
        productLocalUseCase: ProductLocalUseCase,
        needReload: PublishRelay<Void>? = nil
    ) {
        self.prodcut = prodcut
        self.productLocalUseCase = productLocalUseCase
        self.needReload = needReload
    }
}
