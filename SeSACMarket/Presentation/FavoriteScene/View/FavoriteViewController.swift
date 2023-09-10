//
//  FavoriteViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

final class FavoriteViewController: BaseViewController {
 
    // MARK: - Properties
    private let viewModel: FavoriteViewModel
    
    // MARK: - UI
    private let searchBar = DefaultSearchBar()
    private let cancelButton = ButtonStyle1(title: "취소")
    private let productsCollectionView = ProductsCollectionView()
    
    // MARK: - Init
    init(viewModel: FavoriteViewModel) {
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
    
    override func viewWillLayoutSubviews() {
        productsCollectionView.configureLayout()
    }
    
    // MARK: - Configure
    override func configure() {
        super.configure()
        bind()
        [
            searchBar, cancelButton,
            productsCollectionView
        ].forEach { view.addSubview($0) }
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(Constant.Inset.medium)
            $0.trailing.equalTo(cancelButton.snp.leading)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBar)
            $0.trailing.equalToSuperview().inset(Constant.Inset.medium)
        }
        cancelButton.setContentCompressionResistancePriority(
            .defaultHigh,
            for: .horizontal
        )
        
        productsCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(Constant.Inset.defaultInset)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "좋아요 목록"
    }
}

// MARK: - Bind
private extension FavoriteViewController {
    func bind() {
        
    }
}
