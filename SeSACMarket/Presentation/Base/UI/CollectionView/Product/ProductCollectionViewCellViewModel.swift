//
//  ProductCollectionViewCellViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

final class ProductCollectionViewCellViewModel {
    
    let prodcut: Product
    let productLocalRepository: ProductLocalRepository
    
    init(
        prodcut: Product,
        productLocalRepository: ProductLocalRepository
    ) {
        self.prodcut = prodcut
        self.productLocalRepository = productLocalRepository
    }
}
