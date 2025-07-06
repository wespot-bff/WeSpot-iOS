//
//  WSLabel+Extension.swift
//  DesignSystem
//
//  Created by 최지철 on 1/1/25.
//

import UIKit

extension WSLabel {
    public func shakeAnimation() {
        // 1. 좌우 흔들림 애니메이션
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 3
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        
        // 2. 빨간색으로 변경하는 애니메이션
        let originalColor = self.textColor
        UIView.animate(withDuration: 0.3, animations: {
            self.textColor = .red
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.textColor = originalColor
            }
        }
        
        // 3. 레이어에 흔들림 애니메이션 추가
        self.layer.add(shakeAnimation, forKey: "position")
    }
    
    public func fadeOutAnimation(duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
          UIView.animate(withDuration: duration, animations: {
              self.alpha = 0.0
          }) { _ in
              completion?()
          }
      }
}

