//
//  MessageInfoInputViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 1/1/25.
//

import UIKit
import Util
import DesignSystem
import MessageDomain
import Storage

import ReactorKit
import Then
import SnapKit
import RxCocoa
import RxDataSources

public final class MessageInfoInputViewController: BaseViewController<MessageWriteReactor> {
    
    //MARK: - Properties
    
    private let reciverLabel = WSLabel(wsFont: .Body01, text: "받는사람").then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.textAlignment = .left
    }
    private let reciverTextField = WSTextField(state: .default).then {
        $0.isUserInteractionEnabled = false
    }
    private let reciverStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
    }
    private let contentLabel = WSLabel(wsFont: .Body01, text: "전달할 마음").then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.textAlignment = .left
    }
    private let contentTextField = WSTextField(state: .default).then {
        $0.contentVerticalAlignment = .top
        $0.textAlignment = .left
        $0.isUserInteractionEnabled = false
        $0.snp.makeConstraints {
            $0.height.equalTo(170)
        }
    }
    private let contetnTextCountLabel = WSLabel(wsFont: .Body04,
                                                text: "0/200",
                                                textAlignment: .right).then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
        $0.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        $0.isUserInteractionEnabled = false
    }
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
    }
    private let posterLabel = WSLabel(wsFont: .Body01, text: "보내는 사람").then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.textAlignment = .left
    }
    private let posterTextField = WSTextField(state: .default).then {
        $0.isUserInteractionEnabled = false
    }
    private let posterStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
    }
    private let anonymousSendLabel = WSLabel(wsFont: .Body02,
                                            text: "익명으로 보내기")
    private let anonymousDesLabel = WSLabel(wsFont: .Body08,
                                           text: "이 기능을 끄면 실명으로 전송되어요").then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
    }
    private let anonymousToggle = UISwitch().then {
        $0.isOn = true
        $0.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.equalTo(30)
        }
    }
    private let anonymousLabelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
    }
    private let postButton = WSButton(wsButtonType: .default(12))
    
    //MARK: - LifeCycle
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentTextField.becomeFirstResponder()
    }
    
    //MARK: - Configure

    public override func setupUI() {
        super.setupUI()
        [reciverLabel,
         reciverTextField].forEach {
            self.reciverStackView.addArrangedSubview($0)
        }
        [contentLabel,
         contentTextField,
         contetnTextCountLabel].forEach {
            self.contentStackView.addArrangedSubview($0)
        }
        [posterLabel,
         posterTextField].forEach {
            self.posterStackView.addArrangedSubview($0)
        }
        [anonymousSendLabel,
         anonymousDesLabel].forEach {
            self.anonymousLabelStackView.addArrangedSubview($0)
        }
        [reciverStackView,
         contentStackView,
         posterStackView,
         anonymousLabelStackView,
         anonymousToggle,
         postButton].forEach {
            self.view.addSubview($0)
        }
        contentStackView.setCustomSpacing(12, after: contentLabel)
        contentStackView.setCustomSpacing(4, after: contentTextField)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        reciverStackView.snp.makeConstraints {
            $0.top.equalTo(self.navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(reciverStackView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        posterStackView.snp.makeConstraints {
            $0.top.equalTo(contentStackView.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        anonymousLabelStackView.snp.makeConstraints {
            $0.top.equalTo(posterStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(30)
        }
        anonymousToggle.snp.makeConstraints {
            $0.top.equalTo(posterStackView.snp.bottom).offset(34)
            $0.trailing.equalToSuperview().inset(24)
        }
        postButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(MessageConstants.messageSendButtonHeight)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftWithRightItem(DesignSystemAsset.Images.arrow.image,
                                                               "닫기",
                                                        UIImage()))
            $0.setNavigationBarAutoLayout(property: .leftWithRightItem)
        }
        postButton.do {
            $0.isEnabled = true
            $0.setupButton(text: "쪽지 보내기")
        }
        posterTextField.placeholderText = UserDefaultsManager.shared.userName ?? "WeSpot님"
    }
        
    public override func bind(reactor: MessageWriteReactor) {
        super.bind(reactor: reactor)
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindUI()
    }
}

    //MARK: - Bind

extension MessageInfoInputViewController {
    private func bindAction(reactor: MessageWriteReactor) {
        
        navigationBar.rightBarButton.rx
            .tap
            .bind(with: self) {  this, _ in
                WSAlertBuilder(showViewController: this)
                    .setAlertType(type: .titleWithMeesage)
                    .setTitle(title: "쪽지 작성을 중단하시나요?",
                              titleAlignment: .left)
                    .setMessage(message: "작성 중인 내용은 저장되지 않아요")
                    .setConfirm(text: "네 그만할래요")
                    .setCancel(text: "닫기")
                    .action(.confirm)
                    { [weak self] in
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                    .show()
            }
            .disposed(by: disposeBag)
        
        anonymousToggle.rx
            .isOn
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) {  this, value in
                reactor.action.onNext(.anonymousToggle(value))
            }
            .disposed(by: disposeBag)
        
        postButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: {  this, _ in
                WSAlertBuilder(showViewController: this)
                    .setAlertType(type: .titleWithMeesage)
                    .setTitle(title: "쪽지를 예약하시나요?",
                              titleAlignment: .left)
                    .setMessage(message: "오늘 밤 10시에 상대에게 쪽지를 전달해 드릴게요\n예약 후 수정은 가능하지만 전송 취소는 어려워요")
                    .setConfirm(text: "네 예약할래요")
                    .setCancel(text: "닫기")
                    .action(.confirm)
                    {
                        reactor.action.onNext(.sendMessageTapped)
                    }
                    .show()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: MessageWriteReactor) {
        reactor.state
            .map {$0.selectedUser}
            .compactMap {$0}
            .bind(with: self) {  this, reciver in
                this.reciverTextField.placeholderText = reciver.name
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$message)
            .bind(with: self) {  this, message in
                this.contentTextField.placeholderText = message
                this.contetnTextCountLabel.text = "\(message.count)/200"
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$completeSendMessage)
            .observe(on: MainScheduler.instance)
            .bind(with: self) {  this, complete in
                this.navigationController?.popToRootViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    reactor.globalState.event.onNext(.showToast("전송 예약이 완료되었어요!", type: .check))
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindUI() {
        
    }
}
