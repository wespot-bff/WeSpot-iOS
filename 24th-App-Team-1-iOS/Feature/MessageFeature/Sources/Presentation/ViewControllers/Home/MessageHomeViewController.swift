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
    
    private lazy var messageBannerView = WSBanner(image: DesignSystemAsset.Images.reservation.image , titleText: "예약 중인 쪽지 3개").then {
        $0.isHidden = true
    }
    private lazy var messageTimeView = ReservedMessageCountView()
    private lazy var contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.backgroundColor = .clear
    }
    private let bottomInfoLabel = WSLabel(wsFont: .Body06,
                                          text: "서로의 쪽지는 밤 10시에 전달해 드릴게요",
                                          textAlignment: .center).then {
        $0.textColor = DesignSystemAsset.Colors.gray200.color
        $0.sizeToFit()
    }

    
    //MARK: - LifeCycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageTimeView.playLottie()
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
        [bottomInfoLabel, contentStackView].forEach {
            self.view.addSubview($0)
        }
        [messageBannerView,
         messageTimeView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(16, after: messageBannerView)

    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        setInitialLayout()
    }
    
    private func setInitialLayout() {
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        bottomInfoLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(contentStackView.snp.bottom).offset(8)
        }
        
        messageTimeView.snp.makeConstraints {
            $0.height.equalTo(433)
        }
    }
    
    private func animateBanner() {

    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        bottomInfoLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray200.color
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        bindState(reactor: reactor)
        bindAction(reacotr: reactor)
        }
}

extension MessageHomeViewController {
    private func bindState(reactor: MessageHomeViewReactor) {
        
        // 메시지 전송 가능 시간이 변경 및 타이머가 변경될 때마다 UI 업데이트
        Observable.combineLatest(
            reactor.state.compactMap { $0.messageAvailability }.distinctUntilChanged(),
            reactor.state.compactMap { $0.remainingTime }
        )
        .observe(on: MainScheduler.instance)
        .bind(with: self) { this, combined in
            let (availability, remainingTime) = combined
            this.messageTimeView.configureMessageCountView(
                leftTime: remainingTime,
                availableSend: availability.messageAvailabilityTime
            )
            
            let newHeight = MessageConstants.reservedMessageViewHeight(for: availability.messageAvailabilityTime)
            this.messageTimeView.snp.updateConstraints { make in
                make.height.equalTo(newHeight)
            }
            this.view.layoutIfNeeded()
        }
        .disposed(by: disposeBag)
        
        // 예약된 메시지 개수가 변경될 때마다 UI 업데이트
        reactor.pulse(\.$reservedMessages)
            .compactMap { $0 }
            .filter { $0 > 0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, hasReservedMessages in
                this.messageBannerView.isHidden = false
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reacotr: MessageHomeViewReactor) {
        reacotr.action.onNext(.viewDidLoad)
        
        messageTimeView.sendMessageButton.rx.tap
            .bind(with: self) { this, _ in
                this.reactor?.action.onNext(.sendButtonTapped)
            }
            .disposed(by: disposeBag)
    }
}

