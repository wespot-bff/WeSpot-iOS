//
//  VoteToggleView.swift
//  VoteFeature
//
//  Created by Kim dohyun on 7/11/24.
//

import UIKit

import SnapKit
import Then
import DesignSystem


fileprivate typealias VoteStr = VoteStrings
final class VoteToggleView: UIView {
    //MARK: - Properties
    let mainButton: UIButton = UIButton()
    let resultButton: UIButton = UIButton()
    private let selectedLine: UIView = UIView()
    private let underLine: UIView = UIView()
    
    var isSelected: Bool = true {
        didSet {
            updateToggleLayout(isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAttributes()
        setupAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure
    private func setupUI() {
        addSubviews(mainButton, resultButton, underLine, selectedLine)
    }
    
    private func setupAttributes() {
        mainButton.do {
            $0.configuration = .plain()
            $0.configuration?.baseForegroundColor = DesignSystemAsset.Colors.gray100.color
            $0.configuration?.attributedTitle = AttributedString(NSAttributedString(string: VoteStr.voteHomeButtonText, attributes: [
                .font: WSFont.Body03.font(),
            ]))
            $0.configuration?.baseBackgroundColor = .clear
        }
        
        resultButton.do {
            $0.configuration = .plain()
            $0.configuration?.baseBackgroundColor = .clear
            $0.configuration?.baseForegroundColor = DesignSystemAsset.Colors.gray400.color
            $0.configuration?.attributedTitle = AttributedString(NSAttributedString(string: VoteStr.voteResultButtonText, attributes: [
                .font: WSFont.Body03.font(),
            ]))
        }
        
        selectedLine.do {
            $0.backgroundColor = DesignSystemAsset.Colors.gray100.color
        }
        
        underLine.do {
            $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
        }
    }
    
    private func setupAutoLayout() {
        mainButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.left.equalToSuperview().inset(20)
            $0.width.equalTo(self).multipliedBy(0.5).offset(-20)
        }
        resultButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.right.equalToSuperview().inset(20)
            $0.width.equalTo(self).multipliedBy(0.5).offset(-20)
        }
        
        underLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-1)
        }
        
        selectedLine.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(2)
            $0.width.equalTo(self).multipliedBy(0.5).offset(-20)
            $0.bottom.equalToSuperview().offset(-2)
        }
    }
    
    private func updateToggleLayout(_ isSelected: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self else { return }
            self.selectedLine.frame.origin.x = isSelected ? 20 : (self.frame.size.width - self.selectedLine.frame.size.width) - 20
            self.mainButton.configuration?.baseForegroundColor =  isSelected ? DesignSystemAsset.Colors.gray100.color :  DesignSystemAsset.Colors.gray400.color
            self.resultButton.configuration?.baseForegroundColor =  isSelected ? DesignSystemAsset.Colors.gray400.color :  DesignSystemAsset.Colors.gray100.color
        }
    }
}
