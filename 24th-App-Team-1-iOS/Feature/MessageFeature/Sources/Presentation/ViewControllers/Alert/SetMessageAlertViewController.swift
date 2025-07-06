//
//  SetMessageAlertViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 5/31/25.
//

import UIKit
import Util
import DesignSystem
import MessageDomain

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

final class SetMessageAlertViewController: BaseViewController<MessageSettingReactor> {
    
    
    private let titleLabel = WSLabel(wsFont: .Header01)
    private let alertTitleLabel = WSLabel(wsFont: .Body02)
    private let alertDescriptionLabel = WSLabel(wsFont: .Body08).then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
    }
    private let alertStateSwitch = UISwitch()
    private var viewType: MessageSettingListEnum
    
    //MARK: - LifeCycle
    
    init(viewType: MessageSettingListEnum, reactor: MessageSettingReactor) {
        self.viewType = viewType
        super.init()
        super.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Functions
    
    public override func setupUI() {
        super.setupUI()
        self.view.addSubviews(titleLabel,
                              alertTitleLabel,
                              alertDescriptionLabel,
                              alertStateSwitch)
        
        switch viewType {

        case .incomingOutgoing:
            titleLabel.text = String.MessageTexts.messageAlertTitle
            alertTitleLabel.text = String.MessageTexts.getMessageAlertText
            alertDescriptionLabel.text = String.MessageTexts.messageAlertDes
        case .alert:
            titleLabel.text = String.MessageTexts.messageAlertTitle
            alertTitleLabel.text = String.MessageTexts.getMessageAlertText
            alertDescriptionLabel.text = String.MessageTexts.messageAlertDes
            
        default:
            break
        }
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.navigationBar.snp.bottom)
            $0.leading.equalToSuperview().offset(30)
        }

        alertTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(30)
        }
        alertDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(alertTitleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(30)
        }
        alertStateSwitch.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(22)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalTo(52)
            $0.height.equalTo(30)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftIcon(
                DesignSystemAsset.Images.arrow.image
            ))
            $0.setNavigationBarAutoLayout(property: .leftIcon)
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        bindState(reactor: reactor)
        bindAction(reactor: reactor)
    }
    
    private func bindState(reactor: Reactor) {
        switch viewType {
        case .incomingOutgoing:
            reactor.state
                .map {$0.messageAlertState}
                .bind(with: self) { owner, state in
                    owner.alertStateSwitch.isOn = state
                }
                .disposed(by: self.disposeBag)
        case .alert:
            reactor.state
                .map {$0.notificationState}
                .bind(with: self) { owner, state in
                    owner.alertStateSwitch.isOn = state?.isEnableMessageNotification ?? true
                }
                .disposed(by: self.disposeBag)
        default:
            break
        }
    }
    
    private func bindAction(reactor: Reactor) {
        reactor.action.onNext(.fetchMessageStatus)
        reactor.action.onNext(.fetchNotificationStatus)
        switch viewType {
        case .blockList:
            break
        case .incomingOutgoing:
            alertStateSwitch.rx.isOn
                .observe(on: MainScheduler.instance)
                .bind(with: self) { owner, isOn in
                    reactor.action.onNext(.toggleMessageStatus(isOn))
                }
                .disposed(by: self.disposeBag)
        case .alert:
            alertStateSwitch.rx.isOn
                .observe(on: MainScheduler.instance)
                .bind(with: self) { owner, isOn in
                    reactor.action.onNext(.toggleNotificationStatus(isOn))
                }
                .disposed(by: self.disposeBag)
        }
    }
}
