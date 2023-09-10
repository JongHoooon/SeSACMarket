//
//  LikeButton.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

final class LikeButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                setImage(ImageEnum.Icon.heartFilled, for: .normal)
                imageView?.tintColor = .red
            case false:
                setImage(ImageEnum.Icon.heart, for: .normal)
                imageView?.tintColor = .black
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isSelected = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    func playAnimation(completion: @escaping () -> Void) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(
            withDuration: 0.15,
            delay: 0.0,
            options: .curveEaseIn,
            animations: { [weak self] in
                guard let self = self else { return }
                self.imageView?.transform = CGAffineTransform(scaleX: 1.6, y: 1.5)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: .curveEaseIn,
                    animations: {
                        self.imageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    },
                    completion: { _ in
                        completion()
                    })
            })
    }
}
