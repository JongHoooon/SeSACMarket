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
            
            let horizontalInsets = Constants.Inset.defaultInset * 3
            let itemWidth = (self.frame.width - horizontalInsets) / 2
            
            let heightOfImageView = itemWidth
            let heightOfLabels = Constants.FontSize.caption +
            Constants.FontSize.title * 2 +
            Constants.FontSize.bold
            let verticalInsets = Constants.Inset.small * 4
            let cellHeight = heightOfImageView +
                heightOfLabels +
                verticalInsets
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .estimated(cellHeight)
            )
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(cellHeight)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(Constants.Inset.defaultInset)
            group.contentInsets.leading = Constants.Inset.defaultInset
            group.contentInsets.trailing = Constants.Inset.defaultInset
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constants.Inset.defaultInset
            
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
