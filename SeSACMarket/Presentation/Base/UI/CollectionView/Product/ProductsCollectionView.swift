//
//  ProductsCollectionView.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

final class ProductsCollectionView: UICollectionView {
    
    init() {
        super.init(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        keyboardDismissMode = .onDrag
        registerCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLayout() {
        collectionViewLayout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            
            let horizontalInsets = Constant.Inset.defaultInset * 3
            let itemWidth = (self.frame.width - horizontalInsets) / 2
            
            let heightOfImageView = itemWidth
            let heightOfLabels = Constant.FontSize.caption +
            Constant.FontSize.title * 2 +
            Constant.FontSize.bold
            let verticalInsets = Constant.Inset.small * 4
            let groupHeight = heightOfImageView +
                heightOfLabels +
                verticalInsets +
                16.0
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(groupHeight)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(Constant.Inset.defaultInset)
            group.contentInsets.leading = Constant.Inset.defaultInset
            group.contentInsets.trailing = Constant.Inset.defaultInset
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constant.Inset.defaultInset
            
            return section
        }
    }
}

private extension ProductsCollectionView {
    func registerCell() {
        register(
            ProductCollectionViewCell.self,
            forCellWithReuseIdentifier: ProductCollectionViewCell.identifier
        )
    }
}
