//
//  SplashViewController.swift
//  LoginFeature
//
//  Created by 김도현 on 11/29/24.
//

import UIKit

import DesignSystem
import Util
import SnapKit
import Then
import ReactorKit


public final class SplashViewController: BaseViewController<SplashViewReactor> {
    private let logoImageView: UIImageView = UIImageView()
    private let descrptionLabel: WSLabel = WSLabel(wsFont: .Body02, textAlignment: .center)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func setupUI() {
        super.setupUI()
        view.addSubviews(logoImageView, descrptionLabel)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        logoImageView.snp.makeConstraints {
            $0.width.equalTo(183)
            $0.height.equalTo(51)
            $0.center.equalToSuperview()
        }
        
        descrptionLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(12)
            $0.width.equalTo(149)
            $0.height.equalTo(27)
            $0.centerX.equalToSuperview()
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        logoImageView.do {
            $0.image = DesignSystemAsset.Images.logoLarge.image
            $0.contentMode = .scaleToFill
        }
        
        descrptionLabel.do {
            $0.text = "우리가 연결되는 공간"
            $0.textColor = DesignSystemAsset.Colors.white.color
        }
    }
    
    public override func bind(reactor: SplashViewReactor) {
        reactor.pulse(\.$accessToken)
            .map { $0 == nil }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLogin in
                if isLogin {
                    let signInViewController = DependencyContainer.shared.injector.resolve(SignInViewController.self)
                    owner.navigationController?.pushViewController(signInViewController, animated: true)
                } else {
                    NotificationCenter.default.post(name: .showVoteMainViewController, object: nil)
                }
            }
            .disposed(by: disposeBag)
    }
    
}
