//
//  SearchViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class SearchViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    private let productLocalRepository: ProductLocalRepository
    
    // MARK: - UI
    private let searchBar = DefaultSearchBar()
    private let cancelButton = ButtonStyle1(title: "취소")
    private let sortCollectionView = SortCollectionView()
    private let productsCollectionView = ProductsCollectionView()
    
    // MARK: - Init
    init(
        viewModel: SearchViewModel,
        productLocalRepository: ProductLocalRepository
    ) {
        self.viewModel = viewModel
        self.productLocalRepository = productLocalRepository
        super.init(nibName: nil, bundle: nil)
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
        bind()
        sortCollectionView.selectItem(
            at: IndexPath(item: 0, section: 0),
            animated: false,
            scrollPosition: .top
        )
        [
            searchBar, cancelButton,
            sortCollectionView,
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
        
        sortCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(Constant.Inset.defaultInset)
            $0.height.equalTo(Constant.SortCell.height)
            $0.horizontalEdges.equalToSuperview()
        }
        
        productsCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortCollectionView.snp.bottom).offset(Constant.Inset.defaultInset)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "쇼핑 검색"
    }
}

// MARK: - Bind
private extension SearchViewController {
    func bind() {
        bindInput()
        bindOutput()
        
        productsCollectionView.rx.didEndDisplayingCell
            .subscribe(onNext: { event in
                guard let cell = event.cell as? ProductCollectionViewCell else { return }
                cell.cancelTask()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Input
    func bindInput() {
        
        Observable.just(Void())
            .bind(
                with: self,
                onNext: { owner, _ in
                    owner.viewModel.viewDidLoad()
            })
            .disposed(by: disposeBag)
        
        sortCollectionView.rx.modelSelected(SortEnum.self)
            .bind(
                with: self,
                onNext: { owner, sort in
                    owner.viewModel.selectedSortRelay.accept(sort)
            })
            .disposed(by: disposeBag)
        
        let searchBarText = searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
        
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBarText)
            .bind(
                with: self,
                onNext: { owner, text in
                    owner.viewModel.searchBarTextRelay.accept(text)
                    owner.viewModel.searchButtonClicked()
            })
            .disposed(by: disposeBag)
        
        productsCollectionView.rx.prefetchItems
            .bind(
                with: self,
                onNext: { owner, indexPaths in
                    owner.viewModel.prefetchItems(indexPaths: indexPaths)
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .asSignal()
            .emit(
                with: self,
                onNext: { owner, _ in
                    owner.searchBar.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Output
    func bindOutput() {
        
        viewModel.sortItemsRelay
            .asDriver()
            .distinctUntilChanged()
            .drive(sortCollectionView.rx.items(
                cellIdentifier: SortCollectionViewCell.identifier,
                cellType: SortCollectionViewCell.self
            )) { _, sort, cell in
                cell.configureCell(sort: sort)
            }
            .disposed(by: disposeBag)
        
        viewModel.productsItemsRelay
            .asDriver()
            .drive(productsCollectionView.rx.items(
                cellIdentifier: ProductCollectionViewCell.identifier,
                cellType: ProductCollectionViewCell.self
            )) { [weak self] _, product, cell in
                cell.productLocalRepository = self?.productLocalRepository
                cell.configureCell(product: product)
            }
            .disposed(by: disposeBag)
        
        viewModel.scrollContentOffsetRelay
            .asSignal()
            .emit(to: productsCollectionView.rx.contentOffset)
            .disposed(by: disposeBag)
    }
}
