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
        $0.textAlignment = .left

    }
    private let cheveronIcon = UIImageView(image: DesignSystemAsset.Images.arrowRight.image)
    private let dateLabel = WSLabel(wsFont: .Body09).then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
        $0.textAlignment = .right
    }
    
    func configureCell(_ info: AnonymousProfileEntity) {
        let realName = info.isAnonymous ? "" : "(실명)"
        profileImageView.kf.setImage(with: URL(string: info.image))
        nameLabel.text = info.name + realName
        if let dateString = info.recentlyTalk {
            dateLabel.text = formatRecentDate(from: dateString)
        } else {
            dateLabel.text = ""
        }
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
            $0.leading.equalTo(nameLabel.snp.trailing).offset(12)
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
    
    private func formatRecentDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        // 1. 서버에서 받은 날짜 형식("yyyy-MM-dd'T'HH:mm:ss")에 맞춰 Date 객체로 변환합니다.
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX") // 고정된 포맷은 locale을 지정하는 것이 안전합니다.
        
        guard let date = formatter.date(from: dateString) else {
            return "" // 날짜 변환에 실패하면 빈 문자열을 반환합니다.
        }
        
        // 2. 변환된 Date 객체를 원하는 UI 형식("yyyy. M. d")으로 다시 문자열로 만듭니다.
        formatter.dateFormat = "yyyy. M. d"
        let formattedDateString = formatter.string(from: date)
        
        return "최근 \(formattedDateString)"
    }
}
