//
//  TopRightWSLabel.swift
//  DesignSystem
//
//  Created by 최지철 on 1/15/25.
//

import UIKit

public class TopRightWSLabel: WSLabel {
    
    // 오토레이아웃/sizeThatFits 등에 사용되는 영역 계산
    // → 여기서 상단 정렬, 오른쪽 정렬을 위한 x, y 좌표를 조정
    public override func textRect(forBounds bounds: CGRect,
                                  limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        // 슈퍼클래스(WSLabel)의 계산된 텍스트 영역
        var textRect = super.textRect(forBounds: bounds,
                                      limitedToNumberOfLines: numberOfLines)
        
        // (1) 수직 상단 정렬 → y 좌표를 bounds의 맨 위로
        textRect.origin.y = bounds.origin.y
        
        // (2) 수평 오른쪽 정렬 → x 좌표를 bounds의 우측 끝 - 텍스트 폭
        if textAlignment == .right {
            textRect.origin.x = bounds.maxX - textRect.width
        }
        
        return textRect
    }
    
    // 실제 텍스트를 그리는 단계에서, 위에서 계산한 textRect를 사용
    public override func drawText(in rect: CGRect) {
        let actualRect = self.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: actualRect)
    }
}
