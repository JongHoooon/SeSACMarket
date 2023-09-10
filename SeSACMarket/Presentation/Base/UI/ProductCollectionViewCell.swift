//
//  ProductCollectionViewCell.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

import Kingfisher
import SnapKit

final class ProductCollectionViewCell: BaseCollectionViewCell {
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constant.CornerRadius.default
        imageView.backgroundColor = .Custom.grayBackground
        return imageView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 4.0
        return stackView
    }()
    
    private let mallNameLabel: UILabel = {
        let label = UILabel()
        label.text = "몰 네임 라벨"
        label.textColor = .Custom.Text.caption
        label.font = .CustomFont.caption
        return label
    }()
    
    private let titleNameLabel: UILabel = {
        let label = UILabel()
        label.text = "타이틀 라벨"
        label.textColor = .Custom.Text.main
        label.font = .CustomFont.title
        label.numberOfLines = 2
        return label
    }()
    
    private let priceNameLabel: UILabel = {
        let label = UILabel()
        label.text = "33,333"
        label.textColor = .Custom.Text.main
        label.font = .CustomFont.bold
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configure() {
        [
            mallNameLabel,
            titleNameLabel,
            priceNameLabel
        ].forEach { labelStackView.addArrangedSubview($0) }
        
        [
            productImageView,
            labelStackView
        ].forEach { contentView.addSubview($0) }
    }
    
    override func configureLayout() {
        productImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(productImageView.snp.width)
        }
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(4.0)
            $0.leading.equalToSuperview().inset(Constant.Inset.small)
            $0.trailing.equalToSuperview()
        }
    }
    
    func configureCell(product: Product) {
        productImageView.kf.setImage(
            with: URL(string: product.imageURL),
            placeholder: ImageEnum.Placeholer.photo
        )
        mallNameLabel.text = product.mallName.mallNameFormat
        titleNameLabel.text = product.title.htmlEscaped
        priceNameLabel.text = product.price.priceFormat
    }
    
    func cancelImageFetch() {
        productImageView.kf.cancelDownloadTask()
    }
}
