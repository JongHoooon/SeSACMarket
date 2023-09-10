//
//  Reactive+Extension.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import UIKit

import RxSwift

// MARK: - UISearchBar
extension Reactive where Base: UISearchBar {
    var endEditing: Binder<Void> {
        return Binder(self.base) { searchBar, _ in
                searchBar.endEditing(true)
        }
    }
}
