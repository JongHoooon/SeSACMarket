//
//  FavoriteViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import UIKit

import ReactorKit
import RxSwift

final class FavoriteViewController: BaseViewController, View {
    
    // MARK: - UI
    private let searchBar = DefaultSearchBar()
    private let cancelButton = ButtonStyle1(title: "취소")
    private let productsCollectionView = ProductsCollectionView()
    private let settingBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            image: ImageEnum.Icon.gear,
            style: .plain,
            target: nil,
            action: nil
        )
        return barButtonItem
    }()
    
    // MARK: - Init
    init(reactor: FavoriteReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        productsCollectionView.configureLayout()
    }
    
    // MARK: - Configure
    override func configure() {
        super.configure()
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
        navigationItem.backButtonTitle = ""
        navigationItem.rightBarButtonItem = settingBarButton
    }
    
    func bind(reactor: FavoriteReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

private extension FavoriteViewController {
    func bindAction(reactor: FavoriteReactor) {
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .map { Reactor.Action.searchTextInput($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        productsCollectionView.rx.modelSelected(ProductCollectionViewCellViewModel.self)
            .map(\.prodcut)
            .map { Reactor.Action.productCellSelected($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        settingBarButton.rx.tap
            .map { Reactor.Action.settingButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: searchBar.rx.endEditing)
            .disposed(by: disposeBag)
        
        productsCollectionView.rx.didEndDisplayingCell
            .subscribe(onNext: { event in
                guard let cell = event.cell as? ProductCollectionViewCell else { return }
                cell.cancelTask()
            })
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: FavoriteReactor) {
        
        reactor.state.map { $0.productsCellViewModels }
            .compactMap { $0 }
            .bind(to: productsCollectionView.rx.items(
                cellIdentifier: ProductCollectionViewCell.identifier,
                cellType: ProductCollectionViewCell.self
            )) { _, viewModel, cell in
                cell.viewModel = viewModel
                cell.type = .favorite
            }
            .disposed(by: disposeBag)
        
        
        reactor.pulse(\.$scrollContentOffset)
            .compactMap { $0 }
            .bind(to: productsCollectionView.rx.contentOffset)
            .disposed(by: disposeBag)
    }
}
