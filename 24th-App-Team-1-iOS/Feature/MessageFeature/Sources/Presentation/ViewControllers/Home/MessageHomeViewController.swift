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
            reactor.pulse(\.$messageAvailability),
            reactor.state.compactMap { $0.remainingTime }
        )
        .distinctUntilChanged { old, new in
            let (oldAvail, oldTime) = old
            let (newAvail, newTime) = new
            // messageAvailabilityTime과 remainingTime 둘 다 동일하면 true
            return oldAvail.messageAvailabilityTime == newAvail.messageAvailabilityTime
                && oldTime == newTime
        }
        .observe(on: MainScheduler.instance)
        .bind(with: self) { this, combined in
            let (availability, remainingTime) = combined

            let newHeight = MessageConstants.reservedMessageViewHeight(for: availability.messageAvailabilityTime)
            this.messageTimeView.snp.updateConstraints { make in
                make.height.equalTo(newHeight)
            }
            UIView.animate(withDuration: 0.3) {
                this.view.layoutIfNeeded()
            }
            
            this.bottomInfoLabel.isHidden = (availability.messageAvailabilityTime != .waitTime)
            ? false : true
            
            this.bottomInfoLabel.text = availability.messageAvailabilityTime == .postableTime
            ? String.MessageTexts.postableTimeIntroText : String.MessageTexts.waitTimeIntroText
            
            this.messageTimeView.configureMessageCountView(
                leftTime: remainingTime,
                availableSend: availability.messageAvailabilityTime
            )
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
        
        
        messageTimeView.sendMessageButton.rx.tap
            .bind(with: self) { this, _ in
                this.reactor?.action.onNext(.sendButtonTapped)
            }
            .disposed(by: disposeBag)
    }
}

