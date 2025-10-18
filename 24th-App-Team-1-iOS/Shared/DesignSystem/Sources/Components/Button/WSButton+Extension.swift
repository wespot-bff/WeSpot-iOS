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
            self.backgroundColor = DesignSystemAsset.Colors.gray200.color
            self.setTitleColor(DesignSystemAsset.Colors.gray900.color, for: .normal)
            self.tintColor = DesignSystemAsset.Colors.gray900.color
            self.layer.borderWidth = 0
        } else {
            self.backgroundColor = DesignSystemAsset.Colors.gray700.color
            self.setTitleColor(DesignSystemAsset.Colors.gray200.color, for: .normal)
            self.tintColor = DesignSystemAsset.Colors.gray200.color
            self.layer.borderWidth = 0
        }
    }
}
