//
//  BaseViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureLayout()
        configureNavigationBar()
    }
    
    func configure() {
        view.backgroundColor = .Custom.mainBackgroundColor
    }
    
    func configureLayout() {
        
    }
    
    func configureNavigationBar() {
        
    }
}

extension BaseViewController {
    func presentSimpleAlert(
        title: String? = nil,
        message: String,
        handler: (() -> Void)? = nil
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(
            title: "확인",
            style: .default,
            handler: { _ in
                handler?()
            }
        )
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}
