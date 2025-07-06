//
//  DetailMessageView.swift
//  MessageFeature
//
//  Created by 최지철 on 5/13/25.
//

import UIKit
import DesignSystem

final class DetailMessageView: UIView {
    private let messageStatusView = UIView().then {
        $0.layer.cornerRadius = 12
    }
    private let messageStatusLabel = WSLabel(wsFont: .Body08)
        
    private let messageContentLabel = WSTextView(state: .detailMessage).then {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 0
        $0.textColor = DesignSystemAsset.Colors.gray900.color
        $0.font = WSFont.font(.Body03)()
        $0.isScrollEnabled = true
    }
    let replyButton = WSButton(wsButtonType: .default(12))
    let deleteButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.icXmark.image, for: .normal)
    }
    private let backGroundView = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }
    func configureView(isSent: Bool, message: String) {
        if !isSent {
            replyButton.setupButton(text: "답장 보내기")
            messageStatusLabel.text = "보낸쪽지"
            messageStatusView.backgroundColor = UIColor(hex: "#B5D1FF")
            messageStatusLabel.textColor = UIColor(hex: "#3782FF")
            backGroundView.image = DesignSystemAsset.Images.recivedMessageBackground.image
            replyButton.isHidden = true
        } else {
            backGroundView.image = DesignSystemAsset.Images.sentMessageBackground.image
            messageStatusLabel.text = "받은쪽지"
            messageStatusLabel.textColor = UIColor(hex: "#FF5946")
            messageStatusView.backgroundColor = UIColor(hex: "#FFCBC6")
            replyButton.isHidden = false
            replyButton.isEnabled = true
            replyButton.setupButton(text: "답장 보내기")
        }
        messageContentLabel.text = message
        messageContentLabel.font = WSFont.font(.Body04)()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backGroundView)
        self.backGroundView.addSubviews(messageStatusView, messageContentLabel, replyButton, deleteButton)
        self.messageStatusView.addSubview(messageStatusLabel)
        self.backgroundColor = .clear
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        backGroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        messageStatusView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(44)
            $0.leading.equalToSuperview().offset(26)
            $0.width.equalTo(57)
            $0.height.equalTo(24)
        }
        
        messageStatusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(45)
            $0.height.equalTo(16)
        }
        
        replyButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(34)
            $0.bottom.equalToSuperview().inset(42)
            $0.height.equalTo(52)
        }
        
        messageContentLabel.snp.makeConstraints {
            $0.top.equalTo(messageStatusView).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(44)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        deleteButton.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().offset(-18)
        }
    }
    
}
