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
