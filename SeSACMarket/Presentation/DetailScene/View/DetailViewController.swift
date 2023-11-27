//
//  DetailViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import UIKit
import WebKit

import ReactorKit
import RxSwift
import RxCocoa

final class DetailViewController: BaseViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - UI
    private let likeButton: LikeButton = {
        let button = LikeButton(isDetailView: true)
        return button
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: .zero,
            configuration: WKWebViewConfiguration()
        )
        return webView
    }()
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.isHidden = true
        return indicator
    }()

    // MARK: - Init
    init(reactor: DetailReactor) {
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
    
    // MARK: - Configure
    override func configure() {
        super.configure()
        [
            webView,
            indicator
        ].forEach { view.addSubview($0) }
    }
    
    override func configureLayout() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
        navigationItem.title = reactor?.title
    }
    
    func bind(reactor: DetailReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
}

private extension DetailViewController {
    func bindAction(reactor: DetailReactor) {
        self.rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        webView.rx.didFinishLoad
            .map { _ in Reactor.Action.webViewDidFinish }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        webView.rx.didFailLoad.map(\.1)
            .map { Reactor.Action.webViewDidFail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        likeButton.rx.tap
            .compactMap { [weak self] in self?.likeButton.isSelected }
            .map { Reactor.Action.likeButtonTapped($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: DetailReactor) {
        
        reactor.state.map { $0.webViewRequest }
            .distinctUntilChanged()
            .debug()
            .compactMap { $0 }
            .bind(to: webView.rx.load)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isIndicatorAnimating }
            .distinctUntilChanged()
            .bind(to: indicator.rx.isShowAndAnimating)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.likeButtonIsSelected }
            .distinctUntilChanged()
            .bind(to: likeButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.lkieButtonIsSelectedAnimation }
            .distinctUntilChanged()
            .bind(to: likeButton.rx.selectWithAnimation)
            .disposed(by: disposeBag)
    }
}

private extension DetailViewController {
    /*
    func bind() {

        let likeButtonTapped = likeButton.rx.tap
            .map { [weak self] _ in
                return self?.likeButton.isSelected
            }
            .compactMap { $0 }

        // MARK: - Input
        let input = DetailViewModel.Input(
            viewDidLoad: self.rx.viewDidLoad.asObservable(),
            webViewDidFinish: webView.rx.didFinishLoad.map { _ in }.asObservable(),
            webViewDidFail: webView.rx.didFailLoad.map(\.1).asObservable(),
            likeButtonTapped: likeButtonTapped,
            backButtonTapped: Observable.just(Void())
        )
        
        // MARK: - Output
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.title
            .asDriver()
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.webViewRequest
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: webView.rx.load)
            .disposed(by: disposeBag)
        
        output.isIndicatorAnimating
            .asDriver()
            .drive(indicator.rx.isShowAndAnimating)
            .disposed(by: disposeBag)
        
        output.likeButtonIsSelected
            .asDriver()
            .distinctUntilChanged()
            .drive(likeButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.likeButtonIsSelectWithAnimation
            .asSignal()
            .distinctUntilChanged()
            .emit(to: likeButton.rx.selectWithAnimation)
            .disposed(by: disposeBag)
    }
     */
}
