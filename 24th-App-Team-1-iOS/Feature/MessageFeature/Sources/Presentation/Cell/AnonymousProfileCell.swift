//
//  AnonymousProfileCell.swift
//  MessageFeature
//
//  Created by 최지철 on 4/14/25.
//

import UIKit
import DesignSystem
import MessageDomain

import SnapKit
import Kingfisher

final class AnonymousProfileCell: UITableViewCell {
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
    }
    private let nameLabel = WSLabel(wsFont: .Body03, textAlignment: .center).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let cheveronIcon = UIImageView(image: DesignSystemAsset.Images.arrowRight.image)
    private let dateLabel = WSLabel(wsFont: .Body09).then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
        $0.textAlignment = .left
    }
    
    func configureCell(_ info: AnonymousProfileEntity) {
        let realName = info.isAnonymous ? "" : "(실명)"
        profileImageView.kf.setImage(with: URL(string: info.image))
        nameLabel.text = info.name + realName
        dateLabel.text = info.recentlyTalk ?? ""
        nameLabel.sizeToFit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.addSubviews(profileImageView,
                         nameLabel,
                         cheveronIcon,
                         dateLabel)
        
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(34)
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        cheveronIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(cheveronIcon.snp.leading).offset(-12)
            $0.width.equalTo(86)
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        dateLabel.text = nil
    }
}
