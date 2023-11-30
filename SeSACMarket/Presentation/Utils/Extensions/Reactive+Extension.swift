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
    
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillDisappear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewDidDisappear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { _ in }
        return ControlEvent(events: source)
    }
}

// MARK: - BaseViewController
extension Reactive where Base: BaseViewController {
    var isShowIndicator: Binder<Bool> {
        return Binder(self.base) { vc, isShow in
            switch isShow {
            case true:
                vc.view.bringSubviewToFront(vc.indicatorBaseView)
                vc.indicatorBaseView.isHidden = false
                vc.indicatorView.isHidden = false
                vc.indicatorView.startAnimating()
            case false:
                vc.indicatorBaseView.isHidden = true
                vc.indicatorView.isHidden = true
                vc.indicatorView.stopAnimating()
            }
        }
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
                DispatchQueue.main.async {
                    button.isSelected = true
                    button.playAnimation()
                }
            case false:
                DispatchQueue.main.async {
                    button.isSelected = false
                }
            }
        }
    }
}
