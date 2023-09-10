//
//  DefaultSearchBar.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

final class DefaultSearchBar: UISearchBar {
    init() {
        super.init(frame: .zero)
        placeholder = "검색어를 입력해주세요."
        setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
