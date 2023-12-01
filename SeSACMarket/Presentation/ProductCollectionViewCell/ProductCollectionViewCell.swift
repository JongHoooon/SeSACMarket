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
        addActions()
        
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
        productImageView.kf.setImage(
            with: URL(string: reactor.initialState.imageURL),
            placeholder: ImageEnum.Placeholer.photo
        )
        let likeCheckTask = Task {
            let isLike = await reactor.likeUseCase?.isLikeProduct(productID: reactor.initialState.id)

            likeButton.isSelected = isLike ?? false
        }
        self.likeCheckTask = likeCheckTask
        mallNameLabel.text = reactor.initialState.mallName.mallNameFormat
        titleNameLabel.text = reactor.initialState.title
        priceNameLabel.text = reactor.initialState.price.priceFormat
        registerLikeObserver()
    }
    
    func cancelTask() {
        productImageView.kf.cancelDownloadTask()
        likeCheckTask?.cancel()
    }
}

private extension ProductCollectionViewCell {
    
    func addActions() {
        likeButton.addTarget(
            self,
            action: #selector(likeButtonClicked),
            for: .touchUpInside
        )
    }
    
    func registerLikeObserver() {
        NotificationCenter.default.rx.notification(.likeProduct)
            .debug()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, notification in
                let userInfo = notification.userInfo
                guard let id = userInfo?["id"] as? String,
                      let isSelected = userInfo?["isSelected"] as? Bool
                else { return }
                
                if owner.reactor?.initialState.id == id {
                    switch isSelected {
                    case true:
                        owner.likeButton.isSelected = true
                        owner.likeButton.playAnimation()
                    case false :
                        owner.likeButton.isSelected = false
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    func likeButtonClicked() {
        likeButton.isEnabled = false
        guard let product = reactor?.initialState else { return }
        switch likeButton.isSelected {
        case true: // 삭제
            Task {
                do {
                    try await reactor?.likeUseCase?.deleteLikeProduct(productID: product.id)
                    likeButton.isEnabled = true
                    likeButton.isSelected = false
                    if type == .favorite {
                        reactor?.productsCellEventReplay?.accept(.needReload)
                    }
                } catch {
                    reactor?.productsCellEventReplay?.accept(.error(error))
                }
            }
        case false: // 저장
            Task {
                do {
                    try await reactor?.likeUseCase?.saveLikeProduct(product: product)
                    likeButton.isEnabled = true
                    likeButton.isSelected = true
                } catch {
                    reactor?.productsCellEventReplay?.accept(.error(error))
                }
            }
        }
    }
}
