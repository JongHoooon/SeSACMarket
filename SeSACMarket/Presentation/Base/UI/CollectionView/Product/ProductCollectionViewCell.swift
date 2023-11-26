//
//  ProductCollectionViewCell.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

import Kingfisher
import RxSwift
import SnapKit

enum ProductCellType {
    case search
    case favorite
}

final class ProductCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: - Properties
    var viewModel: ProductCollectionViewCellViewModel? {
        didSet {
            guard let product = viewModel?.prodcut else { return }
            configureCell(product: product)
        }
    }
    var type: ProductCellType?
    private var likeCheckTask: Task<(), Never>?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
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
        registerLikeObserver()
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
            $0.bottom.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints {
            $0.size.equalTo(36.0)
            $0.trailing.equalToSuperview().inset(Constant.Inset.medium)
            $0.bottom.equalTo(productImageView.snp.bottom).offset(-Constant.Inset.medium)
        }
        likeButton.layer.cornerRadius = 36.0 / 2
        
    }
    
    func configureCell(product: Product) {
        productImageView.kf.setImage(
            with: URL(string: product.imageURL),
            placeholder: ImageEnum.Placeholer.photo
        )
        let likeCheckTask = Task {
            let isLike = await viewModel?.likeUseCase?.isLikeProduct(productID: product.productID)

            likeButton.isSelected = isLike ?? false
        }
        self.likeCheckTask = likeCheckTask
        mallNameLabel.text = product.mallName.mallNameFormat
        titleNameLabel.text = product.title
        priceNameLabel.text = product.price.priceFormat
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
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, notification in
                let userInfo = notification.userInfo
                guard let id = userInfo?["id"] as? Int,
                      let isSelected = userInfo?["isSelected"] as? Bool
                else { return }
                
                if owner.viewModel?.prodcut.productID == id {
                    switch isSelected {
                    case true:
                        owner.likeButton.isSelected = true
                        owner.likeButton.playAnimation()
                        break
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
        guard let product = viewModel?.prodcut else { return }
        switch likeButton.isSelected {
        case true: // 삭제
            Task {
                do {
                    try await viewModel?.likeUseCase?.deleteLikeProduct(productID: product.productID)
                    likeButton.isEnabled = true
                    if type == .favorite {
                        viewModel?.needReload?.accept(Void())
                    }
                } catch {
                    #warning("수정 필요!!")
//                    viewModel?.errorHandler(error)
                }
            }
        case false: // 저장
            Task {
                do {
                    try await viewModel?.likeUseCase?.saveLikeProduct(product: product)
                } catch {
                    #warning("수정 필요!!")
//                    viewModel?.errorHandler(error)
                }
            }
        }
    }
}
