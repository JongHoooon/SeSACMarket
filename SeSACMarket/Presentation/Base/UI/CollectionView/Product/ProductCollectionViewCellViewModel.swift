//
//  ProductCollectionViewCellViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

final class ProductCollectionViewCellViewModel {
    
    let prodcut: Product
    let productLocalUseCase: ProductLocalUseCase
    
    init(
        prodcut: Product,
        productLocalUseCase: ProductLocalUseCase
    ) {
        self.prodcut = prodcut
        self.productLocalUseCase = productLocalUseCase
    }
}
