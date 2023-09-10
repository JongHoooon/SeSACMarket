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
    
    // MARK: - Properties
    var viewModel: ProductCollectionViewCellViewModel? {
        didSet {
            guard let product = viewModel?.prodcut else { return }
            configureCell(product: product)
        }
    }
    private var likeCheckTask: Task<(), Never>?
    
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
            let isLike = await viewModel?.productLocalRepository.isLikeProduct(productID: product.productID)

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
    
    @objc
    func likeButtonClicked() {
        likeButton.isEnabled = false
        guard let product = viewModel?.prodcut else { return }
        switch likeButton.isSelected {
        case true: // 삭제
            Task {
                do {
                    try await viewModel?.productLocalRepository.deleteLikeProduct(productID: product.productID)
                    
                    likeButton.isSelected.toggle()
                    likeButton.isEnabled = true
                } catch {
                    print(error)
                    return
                }
            }
        case false: // 저장
            Task {
                do {
                    try await viewModel?.productLocalRepository.saveLikeProduct(product: product)
                    
                    likeButton.isSelected.toggle()
                    likeButton.playAnimation(completion: { [weak self] in
                        self?.likeButton.isEnabled = true
                    })
                } catch {
                    print(error)
                    return
                }
            }
        }
    }
}
