//
//  SortCollectionView.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/09.
//

import UIKit

final class SortCollectionView: UICollectionView {
    
    init() {
        super.init(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        registerCell()
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLayout() {
        collectionViewLayout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .estimated(60.0),
                heightDimension: .estimated(Constant.SortCell.height))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(Constant.Inset.medium)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets.leading = Constant.Inset.defaultInset
            section.contentInsets.trailing = Constant.Inset.defaultInset
            return section
        }
    }
}

private extension SortCollectionView {
    func registerCell() {
        register(
            SortCollectionViewCell.self,
            forCellWithReuseIdentifier: SortCollectionViewCell.identifier
        )
    }
}
