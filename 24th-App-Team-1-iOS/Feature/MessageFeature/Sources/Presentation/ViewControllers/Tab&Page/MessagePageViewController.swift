//
//  MessagePageViewController.swift
//  MessageFeature
//
//  Created by eunseou on 7/21/24.
//

import UIKit
import Util

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

public final class MessagePageViewController: UIPageViewController,
                                              View {

    //MARK: - Properties
    public typealias Reactor = MessagePageViewReactor
    private lazy var messageViewControllers: [UIViewController] = [messageHomeViewController, messageStorageViewController]
    private lazy var messageHomeViewController = DependencyContainer.shared.injector.resolve(MessageHomeViewController.self)
    private lazy var messageStorageViewController = DependencyContainer.shared.injector.resolve(MessageStorageViewController.self)
    public var disposeBag: DisposeBag = DisposeBag()
    
    //MARK: - Initialize
    public init(reactor: Reactor) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAttributes()
    }

    //MARK: - Configure
    private func setupUI() {
        setViewController(index: 0)
    }
    
    private func setupAttributes() {
        
        delegate = self
        dataSource = self
        isPagingEnabled = false
    }
    
    private func setViewController(index: Int) {
        
        switch index {
        case 0:
            setViewControllers([messageHomeViewController], direction: .reverse, animated: true)
        case 1:
            setViewControllers([messageStorageViewController], direction: .forward, animated: true)
        default:
            break
        }
    }
    
    public func bind(reactor: Reactor) {
        
        reactor.state
            .map { $0.pageTypes == .home ? 0 : 1 }
            .distinctUntilChanged()
            .bind(with: self) { owner, index in
                owner.setViewController(index: index)
            }
            .disposed(by: disposeBag)
        
        messageHomeViewController.checkUnreadButtonTap
            .bind(with: self) { owner, _ in
                // 탭 이벤트가 발생하면, 두 번째 페이지(index: 1)로 이동하라는 액션을 reactor에 전달합니다.
                // .updateViewController 액션은 이미 pageViewController(_:viewControllerAfter:)에서 사용하고 있으므로 재사용합니다.
                owner.reactor?.action.onNext(.updateViewController(1))
            }
            .disposed(by: disposeBag)
    }
}

extension MessagePageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource  {
   
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = messageViewControllers.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return messageViewControllers[index - 1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = messageViewControllers.firstIndex(of: viewController), index < messageViewControllers.count - 1 else {
            return nil
        }
        reactor?.action.onNext(.updateViewController(index + 1))
        return messageViewControllers[index + 1]
    }
}
