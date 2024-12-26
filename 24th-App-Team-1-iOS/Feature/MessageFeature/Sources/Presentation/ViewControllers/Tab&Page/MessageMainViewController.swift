//
//  MessageMainViewController.swift
//  MessageFeature
//
//  Created by eunseou on 7/21/24.
//

import UIKit
import Util
import DesignSystem

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

public final class MessageMainViewController: BaseViewController<MessageMainViewReactor> {

    //MARK: - Properties
    
    private let messageToggleView: MessageToggleView = MessageToggleView()
    private let messagePageViewController = MessagePageViewController(reactor: MessagePageViewReactor())
    
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
        
        addChild(messagePageViewController)
        view.addSubviews(messageToggleView, messagePageViewController.view)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        messageToggleView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        messagePageViewController.view.snp.makeConstraints {
            $0.top.equalTo(messageToggleView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        navigationBar.do {
            $0.setNavigationBarUI(property: .default)
            $0.setNavigationBarAutoLayout(property: .default)
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        
        self.rx.viewWillAppear
            .bind(with: self) { owner, _ in

            }
            .disposed(by: disposeBag)
        
        messageToggleView.mainButton
            .rx.tap
            .throttle(.milliseconds(300),
                      scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapToggleButton(.home) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        messageToggleView.resultButton
            .rx.tap
            .throttle(.milliseconds(300),
                      scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapToggleButton(.storage) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.messageTypes == .home ? true : false }
            .distinctUntilChanged()
            .skip(1)
            .bind(to: messageToggleView.rx.isSelected)
            .disposed(by: disposeBag)
        
        navigationBar.rightBarButton
            .rx.tap
            .throttle(.milliseconds(300),
                      scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                NotificationCenter.default.post(name: .showNotifcationViewController, object: nil)
            }
            .disposed(by: disposeBag)
        

    }
}

extension MessageMainViewController {

}