//
//  MessageBottomSheetTabelViewCell.swift
//  MessageFeature
//
//  Created by 최지철 on 1/16/25.
//

import UIKit

import DesignSystem

final class MessageBottomSheetTabelViewCell: UITableViewCell {
    private let titleLabel = WSLabel(wsFont: .Body04)
    
    //MARK: - Initialize
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    private func setupUI() {
        
        contentView.addSubviews(titleLabel)
    }
    
    private func setupAutoLayout() {
        

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupAttributes() {
        
        backgroundColor = .clear

        titleLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray100.color
        }
    }
    
    public func configureCell(text: String) {
        titleLabel.text = text
        titleLabel.sizeToFit()
    }

}


