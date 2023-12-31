//
//  ProductCollectionViewCell.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

import Kingfisher
import ReactorKit
import RxSwift
import SnapKit

enum ProductCellType {
    case search
    case favorite
}

final class ProductCollectionViewCell: BaseCollectionViewCell, View {
    
    // MARK: - Properties
    var type: ProductCellType?
    private var likeCheckTask: Task<(), Never>?
    
    // MARK: - UI
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.CornerRadius.default
        imageView.backgroundColor = .Custom.grayBackground
        return imageView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
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
        
    private let likeButton = LikeButton()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    // MARK: - Configure
    override func configure() {
        [
            mallNameLabel,
            titleNameLabel,
            priceNameLabel
        ].forEach { labelStackView.addArrangedSubview($0) }
                
        [
            productImageView,
            labelStackView,
            likeButton
        ].forEach { contentView.addSubview($0) }
    }
    
    override func configureLayout() {
        productImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(productImageView.snp.width)
        }
        
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(4.0)
            $0.leading.equalToSuperview().inset(Constants.Inset.small)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints {
            $0.size.equalTo(36.0)
            $0.trailing.equalToSuperview().inset(Constants.Inset.medium)
            $0.bottom.equalTo(productImageView.snp.bottom).offset(-Constants.Inset.medium)
        }
        likeButton.layer.cornerRadius = 36.0 / 2
    }
    
    func bind(reactor: ProductCollectionViewCellReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func cancelTask() {
        productImageView.kf.cancelDownloadTask()
        likeCheckTask?.cancel()
    }
}

private extension ProductCollectionViewCell {
    
    func bindAction(_ reactor: ProductCollectionViewCellReactor) {
        Observable.just(Void())
            .map { Reactor.Action.checkIsLike }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        likeButton.rx.tap
            .map { Reactor.Action.likeButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: ProductCollectionViewCellReactor) {
        reactor.state.map { $0.likeButtonIsEnable }
            .distinctUntilChanged()
            .bind(to: likeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let isLikeShared = reactor.state.map { $0.isLike }
            .distinctUntilChanged()
            .share()
        
        isLikeShared
            .compactMap { $0 }
            .take(1)
            .bind(to: likeButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        isLikeShared
            .compactMap { $0 }
            .skip(1)
            .bind(to: likeButton.rx.selectWithAnimation)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.product }
            .distinctUntilChanged { $0.id == $1.id }
            .bind { [weak self] product in
                self?.productImageView.kf.setImage(
                    with: URL(string: reactor.initialState.product.imageURL)!,
                    placeholder: ImageEnum.Placeholer.photo,
                    options: [
                        .processor(DownsamplingImageProcessor(size: CGSize(width: 300.0, height: 300.0))),
                        .cacheOriginalImage,
                        .scaleFactor(UIScreen.main.scale),
                    ]
                )
                self?.mallNameLabel.text = reactor.initialState.product.mallName
                self?.titleNameLabel.text = reactor.initialState.product.title
                self?.priceNameLabel.text = reactor.initialState.product.price.priceFormat
            }
            .disposed(by: disposeBag)
    }
}
