//
//  VoteInventoryToggleView.swift
//  VoteFeature
//
//  Created by Kim dohyun on 8/7/24.
//

import DesignSystem
import UIKit


final class VoteInventoryToggleView: UIView {
    let receiveButton: UIButton = UIButton(type: .custom)
    let sentButton: UIButton = UIButton(type: .custom)
    
    
    var isSelected: InventoryType = .receive {
        didSet {
            updateToggleLayout(isSelected: isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAttributes()
        setupAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        addSubviews(receiveButton, sentButton)
    }
    
    private func setupAutoLayout() {
        receiveButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.width.equalTo(76)
            $0.height.equalTo(31)
            $0.centerY.equalToSuperview()
        }
        
        sentButton.snp.makeConstraints {
            $0.left.equalTo(receiveButton.snp.right).offset(12)
            $0.width.height.equalTo(receiveButton)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupAttributes() {
        receiveButton.do {
            $0.configuration = .filled()
            $0.configuration?.baseBackgroundColor = DesignSystemAsset.Colors.gray500.color
            $0.configuration?.baseForegroundColor = DesignSystemAsset.Colors.gray100.color
            $0.configuration?.attributedTitle = AttributedString(NSAttributedString(string: "받은 투표", attributes: [
                .font: WSFont.Body05.font()
            ]))
            $0.layer.cornerRadius = 15
            $0.layer.borderWidth = 0
            $0.layer.borderColor = DesignSystemAsset.Colors.gray400.color.cgColor
            $0.clipsToBounds = true
            
        }
        
        sentButton.do {
            $0.configuration = .filled()
            $0.configuration?.baseBackgroundColor = .clear
            $0.configuration?.baseForegroundColor = DesignSystemAsset.Colors.gray400.color
            $0.configuration?.attributedTitle = AttributedString(NSAttributedString(string: "보낸 투표", attributes: [
                .font : WSFont.Body06.font()
            ]))
            $0.layer.cornerRadius = 15
            $0.layer.borderWidth = 1
            $0.layer.borderColor = DesignSystemAsset.Colors.gray400.color.cgColor
            $0.clipsToBounds = true
        }
    }
    
    
    private func updateToggleLayout(isSelected: InventoryType) {
        receiveButton.configuration?.baseBackgroundColor = isSelected == .receive ? DesignSystemAsset.Colors.gray500.color : .clear
        receiveButton.configuration?.baseForegroundColor = isSelected == .receive ? DesignSystemAsset.Colors.gray100.color : DesignSystemAsset.Colors.gray400.color
        receiveButton.layer.borderWidth = isSelected  == .receive ? 0 : 1
        
        sentButton.configuration?.baseBackgroundColor = isSelected == .sent ? DesignSystemAsset.Colors.gray500.color : .clear
        sentButton.configuration?.baseForegroundColor = isSelected == .sent ? DesignSystemAsset.Colors.gray100.color : DesignSystemAsset.Colors.gray400.color
        sentButton.layer.borderWidth = isSelected == .sent ? 0 : 1
        
    }
    
    
}
