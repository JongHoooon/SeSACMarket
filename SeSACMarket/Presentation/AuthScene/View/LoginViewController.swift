//
//  LoginViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

import RxSwift

final class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: LoginViewModel
    
    // MARK: - UI
    private let loginButton: ButtonStyle1 = {
        let button = ButtonStyle1(title: "로그인 하기")
        button.layer.borderColor = UIColor.Custom.mainTintColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    // MARK: - Init
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configure() {
        super.configure()
        view.addSubview(loginButton)
        bind()
    }
    
    override func configureLayout() {
        loginButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(Constants.Inset.large)
        }
    }
}

private extension LoginViewController {
    
    func bind() {
        let input = LoginViewModel.Input(
            loginButtonTapped: loginButton.rx.tap.asObservable()
        )
        
        let _ = viewModel.transform(input: input, disposeBag: disposeBag)
    }
}
