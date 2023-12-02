//
//  SearchViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

import ReactorKit

import RxCocoa
import RxSwift
import SnapKit

final class SearchViewController: BaseViewController, View {
    
    // MARK: - UI
    private let searchBar = DefaultSearchBar()
    private let cancelButton = ButtonStyle1(title: "취소")
    private let sortCollectionView = SortCollectionView()
    private let productsCollectionView = ProductsCollectionView()
    
    // MARK: - Init
    init(
        reactor: SearchReactor
    ) {
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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        productsCollectionView.configureLayout()
        sortCollectionView.configureLayout()
    }
    
    // MARK: - Configure
    override func configure() {
        super.configure()
        [
            searchBar, cancelButton,
            sortCollectionView,
            productsCollectionView
        ].forEach { view.addSubview($0) }
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(Constants.Inset.medium)
            $0.trailing.equalTo(cancelButton.snp.leading)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBar)
            $0.trailing.equalToSuperview().inset(Constants.Inset.medium)
        }
        cancelButton.setContentCompressionResistancePriority(
            .defaultHigh,
            for: .horizontal
        )
        
        sortCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(Constants.Inset.defaultInset)
            $0.height.equalTo(Constants.SortCell.height)
            $0.horizontalEdges.equalToSuperview()
        }
        
        productsCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortCollectionView.snp.bottom).offset(Constants.Inset.defaultInset)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "쇼핑 검색"
    }
    
    func bind(reactor: SearchReactor) {
        bindAction(reactor)
        bindState(reactor)
        
        cancelButton.rx.tap
            .bind(to: searchBar.rx.endEditing)
            .disposed(by: disposeBag)
    }
}

// MARK: - Bind
private extension SearchViewController {
    func bindAction(_ reactor: SearchReactor) {
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .map { Reactor.Action.searchButtonClicked(query: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sortCollectionView.rx.modelSelected(Product.SortValue.self)
            .map { Reactor.Action.sortSelected($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        productsCollectionView.rx.prefetchItems
            .map { Reactor.Action.prefetchItems($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        productsCollectionView.rx.willDisplayCell.map { $0.at }
            .map { Reactor.Action.productCollectionViewWillDisplayIndexPath($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        productsCollectionView.rx.modelSelected(ProductCollectionViewCellReactor.self)
            .map(\.initialState.product)
            .map { Reactor.Action.productsCellSelected($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: SearchReactor) {
        Observable.just(reactor.sorItems)
            .do(afterNext: { [weak self] _ in
                self?.sortCollectionView.selectItem(
                    at: IndexPath(item: 0, section: 0),
                    animated: false,
                    scrollPosition: .top
                )
            })
            .bind(to: sortCollectionView.rx.items(
                cellIdentifier: SortCollectionViewCell.identifier,
                cellType: SortCollectionViewCell.self
            )) { _, sort, cell in
                cell.configureCell(sort: sort)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.productsCellReactors }
            .bind(to: productsCollectionView.rx.items(
                cellIdentifier: ProductCollectionViewCell.identifier,
                cellType: ProductCollectionViewCell.self
            )) { _, reactor, cell in
                cell.reactor = reactor
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isShowIndicator }
            .distinctUntilChanged()
            .bind(to: self.rx.isShowIndicator)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$scrollContentOffset)
            .bind(to: productsCollectionView.rx.contentOffset)
            .disposed(by: disposeBag)
    }
}
