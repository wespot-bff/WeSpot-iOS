//
//  WSGradientView.swift
//  DesignSystem
//
//  Created by 최지철 on 12/26/24.
//

import UIKit

public final class WSGradientView: UIView {

    //MARK: - Properties
    
    private let gradientLayer = CAGradientLayer()
    
    // 3단계 그라데이션 색상 (투명 → 중간 알파 → 완전 불투명)
    private let gradientColor: [CGColor] = [
        UIColor.clear.cgColor,
        DesignSystemAsset.Colors.gray900.color.withAlphaComponent(0.5).cgColor,
        DesignSystemAsset.Colors.gray900.color.cgColor
    ]
    
    //MARK: - Initializer
    public init() {
        super.init(frame: .zero)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 뷰의 크기에 맞춰 그라데이션 레이어도 업데이트
        gradientLayer.frame = bounds
    }
    
    private func setupGradientLayer() {
        // 그라데이션 레이어의 프레임과 색상, 위치값 설정
        gradientLayer.frame = bounds
        gradientLayer.colors = gradientColor
        
        // [0.0, 0.5, 1.0] → 맨 위 0%에서 시작, 중간(50%) 지점, 맨 아래 100% 지점
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        // 수직 방향(위에서 아래로) 그라데이션
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        // 서브레이어로 삽입
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public weak var passThroughButton: UIButton?
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 만약 gradientView나 하위뷰가 없다면 super 처리
        guard let button = passThroughButton else {
            return super.hitTest(point, with: event)
        }
        
        // 터치 지점을 nextButton의 좌표계로 변환
        let convertedPoint = convert(point, to: button)
        
        // nextButton 범위 안에 있다면 → nextButton이 터치 이벤트 받도록
        if button.bounds.contains(convertedPoint) {
            return button.hitTest(convertedPoint, with: event)
        }
        
        // 그 외 영역이면 → nil로 반환하여 이벤트를 뒤(테이블뷰)로 패스
        return nil
    }
}
