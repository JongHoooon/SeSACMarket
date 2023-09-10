//
//  SortCollectionViewCell.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/09.
//

import UIKit

final class SortCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: - Property
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                baseView.backgroundColor = .Custom.mainTintColor
                sortLabel.textColor = .Custom.mainBackgroundColor
            case false:
                baseView.backgroundColor = .Custom.mainBackgroundColor
                sortLabel.textColor = .Custom.mainTintColor
            }
        }
    }
    
    private let baseView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constant.CornerRadius.default
        view.layer.borderColor = UIColor.Custom.mainTintColor.cgColor
        view.layer.borderWidth = 1.0
        view.clipsToBounds = true
        return view
    }()
    
    private let sortLabel: UILabel = {
        let label = UILabel()
        label.text = "가격낮은순"
        label.textColor = .Custom.Text.main
        label.font = .CustomFont.title
        return label
    }()
    
    override func configure() {
        baseView.addSubview(sortLabel)
        contentView.addSubview(baseView)
    }
    
    override func configureLayout() {

        sortLabel.snp.makeConstraints {
            $0.center.equalTo(baseView)
            $0.horizontalEdges.equalToSuperview().inset(Constant.Inset.medium)
        }
        
        baseView.snp.makeConstraints {
            $0.height.equalTo(Constant.SortCell.height)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    func configureCell(sort: SortEnum) {
        sortLabel.text = sort.title
    }
}
