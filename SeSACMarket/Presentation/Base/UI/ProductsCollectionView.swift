//
//  ProductsCollectionView.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

final class ProductsCollectionView: UICollectionView {
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        registerCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ProductsCollectionView {
    func registerCell() {
        register(
            ProductCollectionViewCell.self,
            forCellWithReuseIdentifier: ProductCollectionViewCell.identifier
        )
    }
    
//    func productsCollectionViewLayout() -> UICollectionViewCompositionalLayout {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(0.5),
//            heightDimension: .fractionalHeight(1.0)
//        )
//        let insets = 16.0 * 3
//        let height
//
//    }
}
