//
//  ProfileAlarmSettingViewController.swift
//  AllFeature
//
//  Created by Kim dohyun on 8/15/24.
//

import DesignSystem
import UIKit
import Util

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

public final class ProfileAlarmSettingViewController: BaseViewController<ProfileAlarmSettingViewReactor> {

    //MARK: - Properties
    private let communityAlarmSettingView: ProfileAlarmSettingView = ProfileAlarmSettingView(contentText: "커뮤니티 알림", descriptionText: "인기 게시글, 댓글 등 게시판 알림", isOn: false)
    private let messageAlarmSettingView: ProfileAlarmSettingView = ProfileAlarmSettingView(contentText: "쪽지 알림", descriptionText: "쪽지, 쪽지 답장 등 쪽지 관련 알림", isOn: false)
    private let sentAlarmSettingView: ProfileAlarmSettingView = ProfileAlarmSettingView(contentText: "비밀 투표", descriptionText: "투표 결과 등 우리 반 비밀 투표 관련 알림", isOn: false)
    private let eventAlarmSettingView: ProfileAlarmSettingView = ProfileAlarmSettingView(contentText: "이벤트 알림", descriptionText: "광고성 정보 수신 동의에 의한 이벤트 혜택 알림", isOn: false)
    private let loadingIndicatorView: WSLottieIndicatorView = WSLottieIndicatorView()
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        view.addSubviews(communityAlarmSettingView, sentAlarmSettingView, messageAlarmSettingView ,eventAlarmSettingView)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        communityAlarmSettingView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
        
        sentAlarmSettingView.snp.makeConstraints {
            $0.top.equalTo(communityAlarmSettingView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
        
        messageAlarmSettingView.snp.makeConstraints {
            $0.top.equalTo(sentAlarmSettingView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
        
        eventAlarmSettingView.snp.makeConstraints {
            $0.top.equalTo(messageAlarmSettingView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(
                property: .leftWithCenterItem(
                    DesignSystemAsset.Images.arrow.image,
                    "알림 설정"
                )
            )
            $0.setNavigationBarAutoLayout(property: .leftWithCenterItem)
        }
        
        sentAlarmSettingView.do {
            $0.backgroundColor = .clear
        }
    
        eventAlarmSettingView.do {
            $0.backgroundColor = .clear
        }
        
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$alarmEntity)
            .compactMap { $0 }
            .map { $0.isEnableVoteNotification }
            .bind(to: sentAlarmSettingView.rx.isOn)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$alarmEntity)
            .compactMap { $0 }
            .map { $0.isEnableMarketingNotification }
            .bind(to: eventAlarmSettingView.rx.isOn)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .bind(to: loadingIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        communityAlarmSettingView.toggleSwitch
            .rx.isOn.changed
            .map { Reactor.Action.didChangeCommunityStatus($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sentAlarmSettingView.toggleSwitch
            .rx.isOn.changed
            .map { Reactor.Action.didChangeVoteStatus($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        eventAlarmSettingView.toggleSwitch
            .rx.isOn.changed
            .map { Reactor.Action.didChangeEventStatus($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
}
