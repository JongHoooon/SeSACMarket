//
//  SettingViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import UIKit

import RxSwift
import RxCocoa

final class SettingViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: SettingViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    private let goLogoutButton: ButtonStyle1 = {
        let button = ButtonStyle1(title: "로그아웃으로 이동")
        button.layer.borderColor = UIColor.Custom.mainTintColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    // MARK: - Init
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        view.addSubview(goLogoutButton)
        bind()
    }
    
    override func configureLayout() {
        goLogoutButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(Constant.Inset.large)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "설정"
    }
}

// MARK: - Bind
private extension SettingViewController {
    
    func bind() {
        
        // MARK: - Input
        let input = SettingViewModel.Input(
            goLogoutButtonTapped: goLogoutButton.rx.tap.asObservable()
        )
        
        // MARK: - Output
        let _ = viewModel.transform(input: input, disposeBag: disposeBag)
    }
}

