//
//  WSButton+Extension.swift
//  DesignSystem
//
//  Created by 최지철 on 1/8/25.
//

import UIKit

extension UIButton {
    public func updateTabStyle(isActive: Bool) {
        if isActive {
            self.backgroundColor = DesignSystemAsset.Colors.gray500.color
            self.setTitleColor(DesignSystemAsset.Colors.gray100.color, for: .normal)
            self.tintColor = DesignSystemAsset.Colors.gray100.color
            self.layer.borderColor = DesignSystemAsset.Colors.gray500.color.cgColor
        } else {
            self.backgroundColor = WSButtonType.tab.buttonProperties.backgroundColor.color
            self.setTitleColor(WSButtonType.tab.buttonProperties.textColor, for: .normal)
            self.layer.borderColor = WSButtonType.tab.buttonProperties.borderColor
        }
    }
}
