//
//  DetailMessageCustomNaviBar.swift
//  MessageFeature
//
//  Created by 최지철 on 5/29/25.
//

import UIKit

import DesignSystem

final class DetailMessageCustomNaviBar: UIView {
    private let nameLabel = WSLabel(wsFont: .Header02)
    let backButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.arrow.image, for: .normal)
    }
    private let userImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
    }

    private let nameStateLabel = WSLabel(wsFont: .Body09).then {
        $0.textColor = .white
    }

    private let bookMarkImg = UIImageView().then {
        $0.image = DesignSystemAsset.Images.icStarGoldFill.image
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    // 스택뷰로 두 뷰를 가로 배치
    private lazy var nameInfoStack = UIStackView(arrangedSubviews: [
        bookMarkImg,
        nameStateLabel
    ]).then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
        $0.layoutMargins = .init(top: 0, left: 8, bottom: 0, right: 8)
        $0.isLayoutMarginsRelativeArrangement = true
        // 배경/코너 설정은 stackView에 해도 됩니다
        $0.backgroundColor = UIColor(hex: "#5A5C6380")
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews(nameLabel, userImageView, nameInfoStack, backButton)
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func layoutUI() {
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        userImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(30)
        }

        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(userImageView.snp.trailing).offset(8)
        }

        nameInfoStack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(userImageView.snp.leading).offset(-8)
            $0.height.equalTo(20)
        }
    }

    // MARK: - Configure

    func configureNavi(name: String,
                      isAnonymous: Bool,
                      imageUrl: URL,
                      isBookmarked: Bool) {
        nameLabel.text = name
        userImageView.kf.setImage(with: imageUrl, placeholder: DesignSystemAsset.Images.icBasicProfile.image)
        bookMarkImg.isHidden = !isBookmarked
        nameStateLabel.text = isAnonymous ? "익명" : "실명"
    }
}
