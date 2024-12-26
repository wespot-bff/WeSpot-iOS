//
//  MessageWriteViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 12/22/24.
//

import UIKit
import Util
import DesignSystem

import Then
import SnapKit
import RxCocoa

public final class MessageWriteViewController: BaseViewController<MessageWriteReactor> {
    //MARK: - Properties
    
    
    //MARK: - LifeCycle
    
    private lazy var titleLabel = WSLabel(wsFont: .Header01).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let studentSearchTextField = WSTextField(state: .withLeftItem(DesignSystemAsset.Images.magnifyingglass.image),
                                                     placeholder: "이름으로 검색해 보세요")
    private let searchResultCollectionView = UICollectionView()
    private let nextButton = WSButton(wsButtonType: .default(12))
    
    //MARK: - Configure

    public override func setupUI() {
        super.setupUI()
    }
    public override func setupAutoLayout() {
        super.setupAutoLayout()
    }
    public override func setupAttributes() {
        super.setupAttributes()
    }
    
    //MARK: - Bind
    
    public override func bind(reactor: MessageWriteReactor) {
        super.bind(reactor: reactor)
    }
}
extension MessageWriteViewController {
    private func bindAction(reactor: MessageWriteReactor) {
        
    }
    private func bindState(reactor: MessageWriteReactor) {
        
    }
}
