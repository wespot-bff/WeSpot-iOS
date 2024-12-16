//
//  VoteMainViewController.swift
//  VoteFeature
//
//  Created by Kim dohyun on 7/11/24.
//

import UIKit
import Util
import Storage

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import DesignSystem

public final class VoteMainViewController: BaseViewController<VoteMainViewReactor> {
    
    //MARK: - Properties
    private let voteToggleView: VoteToggleView = VoteToggleView()
    private lazy var votePageViewController: VotePageViewController = VotePageViewController(reactor: VotePageViewReactor())
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }
    
    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        addChild(votePageViewController)
        view.addSubviews(voteToggleView, votePageViewController.view)
    }

    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        voteToggleView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(VoteConstraint.voteToggleHeight)
        }
        
        votePageViewController.view.snp.makeConstraints {
            $0.top.equalTo(voteToggleView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
    }

    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar
            .setNavigationBarUI(property: .default)
            .setNavigationBarAutoLayout(property: .default)
    }

    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        
        self.rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$updateType)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, updateType in
                switch updateType {
                    
                case let .minor(type):
                    let currentVersion = Bundle.main.appVersion
                    let description = type == "usability" ? "유저의 의견을 반영해서 사용성을 개선했어요\n지금 업데이트하고 더 나은 위스팟을 만나보세요" : "유저의 의견을 반영하여 신규 기능을 출시했어요\n지금 업데이트하고 새로운 위스팟을 만나보세요"
                    guard
                        UserDefaultsManager.shared.lastPromptedVersion.isEmpty ||
                            self.compareVersion(versionA: currentVersion, versionB: UserDefaultsManager.shared.lastPromptedVersion) == .orderedAscending
                    else {
                        return
                    }
                    WSAlertBuilder(showViewController: owner)
                        .setButtonType(type: .all)
                        .setAlertType(type: .titleWithMeesage)
                        .setTitle(title: "새로운 버전이 업데이트 되었어요!")
                        .setMessage(message: description)
                        .setConfirm(text: "업데이트")
                        .setCancel(text: "다음에 할래요")
                        .action(.confirm) {
                            UIApplication.shared.open(WSURLType.appStore.urlString)
                        }
                        .show()
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$voteResponseEntity)
            .compactMap { $0?.response }
            .filter { $0.isEmpty }
            .bind(with: self) { owner, _ in
                let voteBeginViewController = DependencyContainer.shared.injector.resolve(VoteBeginViewController.self)
                owner.navigationController?.pushViewController(voteBeginViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        
        reactor.pulse(\.$voteResponseEntity)
            .map { $0 }
            .filter { !($0?.response.isEmpty ?? true) }
            .bind(with: self) { owner, entity in
                let voteProcessViewController = VoteProcessDIContainer(voteResponseEntity: entity).makeViewController()
                owner.navigationController?.pushViewController(voteProcessViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        voteToggleView.mainButton
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapToggleButton(.main) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        voteToggleView.resultButton
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapToggleButton(.result) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        navigationBar.rightBarButton
            .rx.tap
            .bind(with: self) { owner, _ in
                NotificationCenter.default.post(name: .showNotifcationViewController, object: nil)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.voteTypes == .main ? true : false }
            .distinctUntilChanged()
            .skip(1)
            .bind(to: voteToggleView.rx.isSelected)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isShowEffectView)
            .filter { $0 == true }
            .bind(with: self) { owner, _ in
                let voteEffectViewController = DependencyContainer.shared.injector.resolve(VoteEffectViewController.self)
                owner.navigationController?.pushViewController(voteEffectViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
    }
}


extension VoteMainViewController {
    private func compareVersion(versionA: String, versionB: String) -> ComparisonResult {
        let componentsA = versionA.split(separator: ".").map { Int($0) ?? 0 }
        let componentsB = versionB.split(separator: ".").map { Int($0) ?? 0 }
        
        let count = max(componentsA.count, componentsB.count)
        for i in 0..<count {
            let valueA = i < componentsA.count ? componentsA[i] : 0
            let valueB = i < componentsB.count ? componentsB[i] : 0
            
            if valueA < valueB {
                return .orderedAscending
            } else if valueA > valueB {
                return .orderedDescending
            }
        }
        return .orderedSame
    }
}
