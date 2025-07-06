//
//  WSNavigationBar.swift
//  DesignSystem
//
//  Created by Kim dohyun on 6/30/24.
//

import UIKit

import Extensions
import SnapKit

public final class WSNavigationBar: UIView {
    
    //MARK: Properties
    public var navigationTitleLabel: WSLabel = WSLabel(wsFont: .Header02)
    public let leftBarButton: UIButton = UIButton(type: .custom)
    public let rightBarButton: UIButton = UIButton(type: .custom)
    public let rightBarButton2: UIButton = UIButton(type: .custom) // 두 번째 오른쪽 버튼 추가
    public var navigationProperty: WSNavigationType?
    
    private var hasSecondRightButton: Bool = false // 두 번째 오른쪽 버튼 사용 여부 플래그
    
    //MARK: Initializer
    public init() {
        super.init(frame: .zero)
        setupUI()
        setupAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configure
    private func setupUI() {
        addSubviews(leftBarButton, navigationTitleLabel, rightBarButton, rightBarButton2) // rightBarButton2 추가
    }
    
    private func setupAttributes() {
        backgroundColor = DesignSystemAsset.Colors.gray900.color
        // 기본적으로 두 번째 오른쪽 버튼은 숨김 처리
        rightBarButton2.isHidden = true
    }

    /// WSNavigationBarLayout을 설정하는 메서드 입니다.
    /// - Parameters:
    ///   - property: WSNavigationType을 통해 해당 leftBarButtonItem, rightBarButtonItem, navigationTitleLabel을 설정 해주도록 합니다.
    ///   - secondRightItemImage: (선택 사항) 두 번째 오른쪽 버튼에 설정할 이미지입니다.
    ///   - secondRightItemText: (선택 사항) 두 번째 오른쪽 버튼에 설정할 텍스트입니다.
    ///   - secondRightItemTextColor: (선택 사항) 두 번째 오른쪽 버튼 텍스트의 색상입니다. (기본값: gray100)
    /// - Returns: WSNavigationBar Type을 반환합니다.
    @discardableResult
    public func setNavigationBarUI(
        property: WSNavigationType,
        secondRightItemImage: UIImage? = nil,
        secondRightItemText: String? = nil,
        secondRightItemTextColor: UIColor? = DesignSystemAsset.Colors.gray100.color
    ) -> Self {
        navigationProperty = property
        
        // 왼쪽 버튼 설정
        leftBarButton.setImage(property.items.leftItem, for: .normal)
        
        // 첫 번째 오른쪽 버튼 설정
        rightBarButton.setTitle(property.items.rightTextItem, for: .normal)
        rightBarButton.setImage(property.items.rightImageItem, for: .normal)
        rightBarButton.setTitleColor(property.items.rightTextItemColor, for: .normal)
        rightBarButton.titleLabel?.font = WSFont.Body04.font()
        let firstButtonHasContent = property.items.rightImageItem != nil || property.items.rightTextItem != nil
        rightBarButton.isHidden = !firstButtonHasContent
        
        // 두 번째 오른쪽 버튼 설정 (이미지 또는 텍스트가 제공된 경우)
        let secondButtonHasContent = secondRightItemImage != nil || secondRightItemText != nil
        if secondButtonHasContent {
            rightBarButton2.setImage(secondRightItemImage, for: .normal)
            rightBarButton2.setTitle(secondRightItemText, for: .normal)
            rightBarButton2.setTitleColor(secondRightItemTextColor, for: .normal)
            rightBarButton2.titleLabel?.font = WSFont.Body04.font() // 첫 번째 버튼과 동일한 폰트 사용 가정
            rightBarButton2.isHidden = false
            self.hasSecondRightButton = true
        } else {
            rightBarButton2.isHidden = true
            self.hasSecondRightButton = false
        }
        
        // 네비게이션 타이틀 설정
        navigationTitleLabel.text = property.items.centerItem
        navigationTitleLabel.textColor = DesignSystemAsset.Colors.gray100.color
        
        return self
    }
    
    /// WSNavigationBar AutoLayout을 설정하는 메서드 입니다.
    /// 이 메서드는 하나 또는 두 개의 오른쪽 버튼을 처리하도록 업데이트되었습니다.
    /// 두 번째 오른쪽 버튼은 첫 번째 오른쪽 버튼과 동일한 크기 및 위쪽 간격을 사용하며, 기본 내부 간격(8pt)으로 배치됩니다.
    /// - Parameters:
    ///   - property: WSNavigationPropertyType을 통해 해당 leftBarButtonItem, rightBarButtonItem의 Spacing, Scale 값을 설정하도록 합니다.
    /// - Returns: WSNavigationBar Type을 반환합니다.
    public func setNavigationBarAutoLayout(property: WSNavigationPropertyType) {
        
        leftBarButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(property.constraints.leftBarButtonItemLeftSpacing)
            $0.top.equalToSuperview().offset(property.constraints.leftBarButtonItemTopSpacing)
            $0.width.equalTo(property.constraints.leftWidthScale)
            $0.height.equalTo(property.constraints.leftHeightScale)
        }
        
        navigationTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // 오른쪽 버튼들의 제약조건을 초기화 (동적 변경을 위함)
        rightBarButton.snp.removeConstraints()
        rightBarButton2.snp.removeConstraints()

        if hasSecondRightButton && !rightBarButton2.isHidden {
            // 두 개의 오른쪽 버튼 레이아웃 설정
            // rightBarButton2 (오른쪽 끝에 위치)
            rightBarButton2.snp.makeConstraints {
                $0.right.equalToSuperview().offset(-property.constraints.rightBarButtonItemRightSpacing)
                $0.top.equalToSuperview().offset(property.constraints.rightBarButtonItemTopSpacing)
                $0.width.equalTo(property.constraints.rightWidthScale) // 첫 번째 버튼과 동일한 크기 사용 가정
                $0.height.equalTo(property.constraints.rightHeightScale) // 첫 번째 버튼과 동일한 크기 사용 가정
            }
            
            // rightBarButton (rightBarButton2 왼쪽에 위치)
            // rightBarButton도 내용이 있어서 보이는 경우에만 레이아웃 설정
            if !rightBarButton.isHidden {
                let spacingBetweenButtons: CGFloat = 8 // 버튼 사이의 간격 (필요시 WSNavigationPropertyType 통해 설정 가능하도록 변경 가능)
                rightBarButton.snp.makeConstraints {
                    $0.right.equalTo(rightBarButton2.snp.left).offset(-spacingBetweenButtons)
                    $0.top.equalTo(rightBarButton2.snp.top) // Y축 정렬
                    $0.width.equalTo(property.constraints.rightWidthScale) // 첫 번째 버튼과 동일한 크기 사용 가정
                    $0.height.equalTo(property.constraints.rightHeightScale) // 첫 번째 버튼과 동일한 크기 사용 가정
                }
            }
        } else if !rightBarButton.isHidden {
            // 한 개의 오른쪽 버튼 (rightBarButton) 레이아웃 설정 (기존 방식)
            rightBarButton.snp.makeConstraints {
                $0.right.equalToSuperview().offset(-property.constraints.rightBarButtonItemRightSpacing)
                $0.top.equalToSuperview().offset(property.constraints.rightBarButtonItemTopSpacing)
                $0.width.equalTo(property.constraints.rightWidthScale)
                $0.height.equalTo(property.constraints.rightHeightScale)
            }
        }
        // 두 버튼 모두 숨겨진 경우, 제약조건을 설정하지 않음 (이미 removeConstraints() 호출됨)
    }
}
