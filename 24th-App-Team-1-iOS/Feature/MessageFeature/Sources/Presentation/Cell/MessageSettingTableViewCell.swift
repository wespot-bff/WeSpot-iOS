//
//  MessageSettingTableViewCell.swift
//  MessageFeature
//
//  Created by 최지철 on 5/29/25.
//

import UIKit

import DesignSystem

class MessageSettingTableViewCell: UITableViewCell {
    
    private let titleLabel = WSLabel(wsFont: .Body04)
    private let chevronIcon = UIImageView(image: DesignSystemAsset.Images.arrowRight.image)
    
    func configureCell(title: String) {
        titleLabel.text = title
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubviews(titleLabel, chevronIcon)
        self.backgroundColor = .clear
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        chevronIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
