//
//  TermsBottomSheetViewController.swift
//  VoteFeature
//
//  Created by 김도현 on 10/14/25.
//

import UIKit
import SnapKit
import Then
import DesignSystem
import Util
import AllFeature

import RxSwift
import RxCocoa

protocol TermsBottomSheetViewControllerDelegate: AnyObject {
    func termsBottomSheetDidTapResign()
}


public final class TermsBottomSheetViewController: UIViewController {
    weak var delegate: TermsBottomSheetViewControllerDelegate?
    private let disposeBag: DisposeBag = DisposeBag()
    private let dimmedView: UIView = UIView()
    private let contentView: UIView = UIView()
    private let termsButton: UIButton = UIButton(type: .custom)
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAttributes()
        setupAutoLayout()
        bind()
    }
    
    private func setupUI() {
        view.addSubviews(dimmedView, contentView)
        
        contentView.addSubviews(termsButton)
    }
    
    private func setupAutoLayout() {
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(108)
            $0.bottom.equalToSuperview()
        }
        
        termsButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
    }
    
    private func setupAttributes() {
        
        dimmedView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        }
        
        contentView.do {
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 25
            $0.clipsToBounds = true
            $0.backgroundColor = DesignSystemAsset.Colors.gray600.color
        }
        
        termsButton.do {
            $0.setTitle("탈퇴하기", for: .normal)
            $0.setTitleColor(DesignSystemAsset.Colors.gray100.color, for: .normal)
            $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 16)
            $0.addTarget(self, action: #selector(didTappedTemrsButton), for: .touchUpInside)
        }
        
    }
    
    @objc
    private func didTappedDimview() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func didTappedTemrsButton() {
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.termsBottomSheetDidTapResign()
        }
    }
    
    private func bind() {
        dimmedView
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
