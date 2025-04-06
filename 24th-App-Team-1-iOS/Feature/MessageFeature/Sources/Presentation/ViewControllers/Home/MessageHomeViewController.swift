//
//  MessageHomeViewController.swift
//  MessageFeature
//
//  Created by eunseou on 7/20/24.
//

import UIKit
import Util
import DesignSystem

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

public final class MessageHomeViewController: BaseViewController<MessageHomeViewReactor> {
    
    //MARK: - Properties
    private let globalState: WSGlobalServiceProtocol = WSGlobalStateService.shared
    private lazy var messageMainView = ReservedMessageCountView()
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.backgroundColor = .clear
    }

    private let checkUnReadMessageButton = CountUnReadMessageView()

    
    //MARK: - LifeCycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageMainView.playLottie()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setInitialLayout()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    //MARK: - Functions
    public override func setupUI() {
        super.setupUI()
        [contentStackView].forEach {
            self.view.addSubview($0)
        }
        [checkUnReadMessageButton,
         messageMainView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(16, after: checkUnReadMessageButton)

    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        setInitialLayout()
    }
    
    private func setInitialLayout() {
        checkUnReadMessageButton.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        messageMainView.snp.makeConstraints {
            $0.height.equalTo(433)
        }
    }
    
    private func animateBanner() {

    }
    
    public override func setupAttributes() {
        super.setupAttributes()

    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        bindState(reactor: reactor)
        bindAction(reacotr: reactor)
    }
}

extension MessageHomeViewController {
    private func bindState(reactor: MessageHomeViewReactor) {
        
        
        reactor.pulse(\.$haveMessage)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, haveMessage in
                this.checkUnReadMessageButton.isHidden = !haveMessage
            }
            .disposed(by: disposeBag)
        
        
        
        Observable.combineLatest(
            reactor.pulse(\.$postableMessageCount),
            reactor.state.compactMap { $0.remainingTime }
        )
        .observe(on: MainScheduler.instance)
        .bind { [weak self] count, remainingTime in
            self?.messageMainView.configure(count: count, time: remainingTime)
        }
        .disposed(by: disposeBag)
        
        globalState.event
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) {  this, type in
                switch type {
                case .showToast(let message, let type):
                    this.showWSToast(image: type, message: message)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        
    }
    
    private func bindAction(reacotr: MessageHomeViewReactor) {
        reacotr.action.onNext(.viewWillAppear)
        self.rx.viewWillAppear
            .bind { _ in
                reacotr.action.onNext(.viewWillAppear)
            }
            .disposed(by: disposeBag)
        
        self.rx.viewDidDisappear
            .bind { _ in
                reacotr.action.onNext(.viewDisappeared)
            }
            .disposed(by: disposeBag)
        
        
        messageMainView.sendMessageButton.rx.tap
            .bind(with: self) { this, _ in
                this.reactor?.action.onNext(.sendButtonTapped)
            }
            .disposed(by: disposeBag)
    }
}

