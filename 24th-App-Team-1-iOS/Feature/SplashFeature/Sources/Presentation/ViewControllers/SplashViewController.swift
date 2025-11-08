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
    private let mainImageView: UIImageView = UIImageView()
//    private let descrptionLabel: WSLabel = WSLabel(wsFont: .Body02, textAlignment: .center)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func setupUI() {
        super.setupUI()
        view.addSubviews(mainImageView)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        mainImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        mainImageView.do {
            $0.image = DesignSystemAsset.Images.splashImg.image
            $0.contentMode = .scaleToFill
        }

    }
    
    public override func bind(reactor: SplashViewReactor) {
        super.bind(reactor: reactor)
        
        NotificationCenter.default
            .rx.notification(UIApplication.willEnterForegroundNotification)
            .map { _ in Reactor.Action.willEnterForeground }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable
            .zip(
                reactor.state.map { $0.accessToken },
                reactor.state.map { $0.updateType }
            )
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, arg in
                switch arg.1 {
                case .major:
                    WSAlertBuilder(showViewController: owner)
                        .setAlertType(type: .titleWithMeesage)
                        .setButtonType(type: .confirm)
                        .setTitle(title: "새로운 버전이 업데이트 되었어요!")
                        .setMessage(message: "위스팟을 계속 이용하시려면 최신 버전 업데이트가 필요해요 지금 바로 업데이트하고 새로운 위스팟을 만나로 가볼까요?")
                        .setConfirm(text: "업데이트")
                        .action(.confirm) {
                            UIApplication.shared.open(WSURLType.appStore.urlString)
                        }
                        .show()
                default:
                    if arg.0 == nil {
                        NotificationCenter.default.post(name: .showSignInViewController, object: nil)
                    } else {
                        NotificationCenter.default.post(name: .showVoteMainViewController, object: nil)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
