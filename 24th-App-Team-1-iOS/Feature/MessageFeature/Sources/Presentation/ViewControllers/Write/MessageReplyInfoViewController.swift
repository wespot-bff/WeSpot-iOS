//
//  MessageReplyInfoViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 6/29/25.
//

import UIKit
import Util
import DesignSystem
import MessageDomain
import Storage

import ReactorKit
import Then
import SnapKit
import Kingfisher
import RxCocoa
import RxDataSources

public final class MessageReplyInfoViewController: BaseViewController<MessageWriteReactor> {
    
    //MARK: - Properties
    
    private let reciverLabel = WSLabel(wsFont: .Body01, text: "받는사람").then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.textAlignment = .left
    }
    
    private let reciverView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
    }
    private let reciverImageView = UIImageView().then {
        $0.layer.cornerRadius = 15
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let reciverName = WSLabel(wsFont: .Body04)

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
        $0.textColor = .white
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
    private let posterView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
    }
    private let posterImageView = UIImageView().then {
        $0.layer.cornerRadius = 15
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let posterName = WSLabel(wsFont: .Body04)
    private let posterStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
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
         reciverView].forEach {
            self.reciverStackView.addArrangedSubview($0)
        }
        
        reciverView.addSubviews(reciverImageView, reciverName)
        
        [contentLabel,
         contentTextField,
         contetnTextCountLabel].forEach {
            self.contentStackView.addArrangedSubview($0)
        }
        [posterLabel,
         posterView].forEach {
            self.posterStackView.addArrangedSubview($0)
        }
        posterView.addSubviews(posterName, posterImageView)

        [reciverStackView,
         contentStackView,
         posterStackView,
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

        postButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(MessageConstants.messageSendButtonHeight)
        }
        
        reciverImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        reciverName.snp.makeConstraints {
            $0.leading.equalTo(reciverImageView.snp.trailing).offset(5)
            $0.centerY.equalToSuperview()
        }
        
        posterView.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        reciverView.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        posterImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        posterName.snp.makeConstraints {
            $0.leading.equalTo(posterImageView.snp.trailing).offset(5)
            $0.centerY.equalToSuperview()
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
            $0.setupButton(text: "답장 보내기")
        }
    }
        
    public override func bind(reactor: MessageWriteReactor) {
        super.bind(reactor: reactor)
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindUI()
    }
}

    //MARK: - Bind

extension MessageReplyInfoViewController {
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

        
        postButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: {  this, _ in
                WSAlertBuilder(showViewController: this)
                    .setAlertType(type: .titleWithMeesage)
                    .setTitle(title: "답장을 전달할게요",
                              titleAlignment: .left)
                    .setMessage(message: "쪽지 전송 후에는 수정이나 전송 취소가 불가하며\n남은 쪽지 개수에서 1개가 차감돼요")
                    .setConfirm(text: "네 좋아요!")
                    .setCancel(text: "닫기")
                    .action(.confirm)
                    {
                        reactor.action.onNext(.setndReplyMessgaeTapped)
                    }
                    .show()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: MessageWriteReactor) {
        reactor.state.map{$0.replyMessage}
            .bind(with: self) {  this, info in
                this.posterName.text = info?.senderProfile.name
                this.posterImageView.kf.setImage(with: URL(string: info?.senderProfile.iconUrl ?? ""),
                                                 placeholder: DesignSystemAsset.Images.icBasicProfile.image)
                this.reciverName.text = (info?.receiverProfile.name ?? "") + "|" + (info?.receiverProfile.schoolName ?? "")
                this.reciverImageView.kf.setImage(with: URL(string: info?.receiverProfile.iconUrl ?? ""),
                                                  placeholder: DesignSystemAsset.Images.icBasicProfile.image)

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
                if complete {
                    this.navigationController?.popToRootViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        reactor.globalState.event.onNext(.showToast("전송 완료!", type: .check))
                    }
                } else {
                    this.navigationController?.popToRootViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        reactor.globalState.event.onNext(.showToast("메시지 전송이 실패했어요 :(", type: .warning))
                    }
                }

            }
            .disposed(by: disposeBag)
    }
    
    private func bindUI() {
        
    }
}
