//
//  ButtonStyle1.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

final class ButtonStyle1: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.Text.main, for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
