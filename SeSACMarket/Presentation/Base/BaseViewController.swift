//
//  BaseViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let indicatorBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()
    
    let indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.isHidden = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureLayout()
        configureNavigationBar()
    }
    
    func configure() {
        view.backgroundColor = .Custom.mainBackgroundColor
        view.addSubview(indicatorBaseView)
        indicatorBaseView.addSubview(indicatorView)
        indicatorBaseView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func configureLayout() {
        
    }
    
    func configureNavigationBar() {
        
    }
}
