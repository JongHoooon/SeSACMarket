//
//  BaseCollectionViewCell.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
    }
    
    func configureLayout() {
        
    }
}
