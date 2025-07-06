//
//  WSMakeAnonymousProfileButton.swift
//  DesignSystem
//
//  Created by 최지철 on 4/15/25.
//

import UIKit

public final class WSMakeAnonymousProfileButton: UIButton {

    private let plusImageView = UIImageView(image: DesignSystemAsset.Images.icPlus.image).then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
    }
    private let circleView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.primary100.color
        $0.layer.cornerRadius = 17
    }
    private let titleWSLabel = WSLabel(wsFont: .Body03).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    public convenience init(title: String) {
        self.init()
        self.titleWSLabel.text = title
        self.titleWSLabel.sizeToFit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        plusImageView.snp.makeConstraints {
            $0.size.equalTo(12)
            $0.center.equalToSuperview()
        }
        circleView.snp.makeConstraints {
            $0.size.equalTo(34)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        titleWSLabel.snp.makeConstraints {
            $0.leading.equalTo(circleView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        circleView.addSubview(plusImageView)
        self.addSubviews(circleView, titleWSLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
