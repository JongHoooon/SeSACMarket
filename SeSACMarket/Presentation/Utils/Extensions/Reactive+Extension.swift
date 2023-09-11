//
//  Reactive+Extension.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa

// MARK: - UIViewConttroller
extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = Observable.just(Void())
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Bool> {
      let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
      return ControlEvent(events: source)
    }
}

// MARK: - UISearchBar
extension Reactive where Base: UISearchBar {
    var endEditing: Binder<Void> {
        return Binder(self.base) { searchBar, _ in
                searchBar.endEditing(true)
        }
    }
}

// MARK: - WKWebView
extension Reactive where Base: WKWebView {
    var load: Binder<URLRequest> {
        return Binder(self.base) { webView, request in
            webView.load(request)
        }
    }
}

// MARK: - UIActivityIndicatorView
extension Reactive where Base: UIActivityIndicatorView {
    var isShowAndAnimating: Binder<Bool> {
        return Binder(self.base) { indicator, bool in
            switch bool {
            case true:
                indicator.startAnimating()
                indicator.isHidden = false
            case false:
                indicator.isHidden = true
                indicator.stopAnimating()
            }
        }
    }
}

// MARK: - Like Button
extension Reactive where Base: LikeButton {
    var selectWithAnimation: Binder<Bool> {
        return Binder(self.base) { button, bool in
            switch bool {
            case true:
                button.isSelected = true
                button.playAnimation()
            case false:
                button.isSelected = false
            }
        }
    }
}
