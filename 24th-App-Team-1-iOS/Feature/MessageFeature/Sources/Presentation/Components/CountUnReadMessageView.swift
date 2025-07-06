//
//  CountUnReadMessageView.swift
//  MessageFeature
//
//  Created by 최지철 on 4/6/25.
//

import UIKit
import DesignSystem

import SnapKit
import RxSwift
import RxCocoa

final class CountUnReadMessageView: UIButton {
    
    private let messageIcon = UIImageView(image: DesignSystemAsset.Images.icHeartMessage.image)
    private let titleDesLabel = WSLabel(wsFont: .Body04, text: String.MessageTexts.waitRepeatMessage)
    private let desLabel = WSLabel(wsFont: .Body07, text: String.MessageTexts.checkMessageButtonText).then {
        $0.textColor = DesignSystemAsset.Colors.primary300.color
    }
    private let cheveronIcon = UIImageView(image: DesignSystemAsset.Images.arrowRight.image)
    
    private func layout() {
        messageIcon.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.height.equalTo(21)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        titleDesLabel.sizeToFit()
        titleDesLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.equalTo(messageIcon.snp.trailing).offset(16)
        }
        desLabel.sizeToFit()
        desLabel.snp.makeConstraints {
            $0.top.equalTo(titleDesLabel.snp.bottom)
            $0.leading.equalTo(messageIcon.snp.trailing).offset(16)
        }
        
        cheveronIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
        self.layer.cornerRadius = 14
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews(messageIcon, titleDesLabel, desLabel, cheveronIcon)
        self.backgroundColor = DesignSystemAsset.Colors.gray600.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

