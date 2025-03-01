//
//  SceneDelegate.swift
//  wespot
//
//  Created by Kim dohyun on 6/27/24.
//

import UIKit
import Util
import Storage
import DesignSystem

import LoginFeature
import SplashFeature
import CommonDomain
import LoginDomain
import LoginService
import VoteFeature
import Firebase
import VoteService
import AllFeature
import NotificationFeature
import Swinject
import RxKakaoSDKAuth
import KakaoSDKAuth
import MessageFeature
import KeychainSwift


public class SceneDelegate: UIResponder, UISceneDelegate {
    
    var window: UIWindow?
    private let notificationHandler = WSNotificationHandler()
    
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        DependencyContainer.shared.injector.assemble([
            SplashPresentationAssembly(),
            SignInPresentationAssembly(),
            SignUpNamePresentationAssembly(),
            SignUpClassPresentationAssembly(),
            SignUpGenderPresentationAssembly(),
            SignUpResultPresentationAssembly(),
            SignUpGradePresentationAssembly(),
            SignUpCompletePresentationAssembly(),
            SignUpSchoolPresentationAssembly(),
            VotePresentationAssembly(),
            VoteEffectPresentationAssembly(),
            VoteMainPresentationAssembly(),
            VoteHomePresentationAssembly(),
            VotePagePresentationAssembly(),
            VoteResultPresentationAssembly(),
            VoteCompletePresentationAssembly(),
            VoteInventoryPresentationAssembly(),
            VoteInventoryDetailPresentationAssembly(),
            MessageMainPresentationAssembly(),
            MessagePagePresentationAssembly(),
            MessageHomePresentationAssembly(),
            AllMainPresentationAssembly(),
            AllMainProfilePresentationAssembly(),
            AllMainProfileWebPresentationAssembly(),
            AllMainProfileSettingPresentationAssembly(),
            AllMainProfileAlarmSettingPresentationAssembly(),
            AllMainProfileUserBlockPresentationAssembly(),
            AllMainProfileAccountSettingPresentationAssembly(),
            AllMainProfileResignNotePresentationAssembly(),
            MessageReportPresentationAssembly(),
            AllMainProfileResignPresentationAssembly(),
            NotificationPresentationAssembly(),
            DataAssembly(),
            DomainAssembly()
        ])
        
        window = UIWindow(windowScene: scene)
        UNUserNotificationCenter.current().delegate = notificationHandler
        
        let accessToken = KeychainManager.shared.get(type: .accessToken)
        let refreshToken = KeychainManager.shared.get(type: .refreshToken)
    
        let splashViewController = DependencyContainer.shared.injector.resolve(SplashViewController.self, argument: accessToken)
        window?.rootViewController = UINavigationController(rootViewController: splashViewController)
        setupViewControllers()
        window?.makeKeyAndVisible()
    }
    
    
    // kakao login
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
}

extension SceneDelegate {
    
    //TODO: Coordinator 패턴으로 수정
    private func setupViewControllers() {
        
        
        NotificationCenter.default.addObserver(forName: .dismissProfileOnboardingView, object: nil, queue: .main) { [weak self]  _ in
            guard let self else { return }
            setupMainViewController()
            
            let rootViewController = self.window?.rootViewController?.topMostViewController()
            
            let profileOnboardingViewController = ProfileOnboardingHostingViewController(rootView: ProfileOnboardingView(viewModel: ProfileOnboardingViewModel()))
            rootViewController?.navigationController?.pushViewController(profileOnboardingViewController, animated: false)
            
        }
        
        NotificationCenter.default.addObserver(forName: .showProfileOnboardingView, object: nil, queue: .main) { _ in
            guard let topViewController = self.window?.rootViewController else { return }
            let profileOnboardingViewController = ProfileOnboardingHostingViewController(rootView: ProfileOnboardingView(viewModel: ProfileOnboardingViewModel()))
            topViewController.navigationController?.pushViewController(profileOnboardingViewController, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .showVoteMainViewController, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            setupMainViewController()
        }
        
        NotificationCenter.default.addObserver(forName: .showProfileSettingViewController, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            let topViewController = self.window?.rootViewController?.topMostViewController()
            let profileSettingViewController = DependencyContainer.shared.injector.resolve(ProfileSettingViewController.self)
            if let navigationController = topViewController?.navigationController {
                navigationController.popViewController(animated: false)
                navigationController.pushViewController(profileSettingViewController, animated: true)
            }
        }

        
        NotificationCenter.default.addObserver(forName: .showSignInViewController, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            let signInViewController = DependencyContainer.shared.injector.resolve(SignInViewController.self)
            self.window?.rootViewController = UINavigationController(rootViewController: signInViewController)
        }
        
        NotificationCenter.default.addObserver(forName: .showNotifcationViewController, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            let topViewController = self.window?.rootViewController?.topMostViewController()
            let notificationViewController = DependencyContainer.shared.injector.resolve(NotificationViewController.self)
            topViewController?.navigationController?.pushViewController(notificationViewController, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .showVoteProccessController, object: nil, queue: .main) { [weak self] notification in
            guard let self else { return }
            let topViewController = self.window?.rootViewController?.topMostViewController()
            let voteOption = notification.userInfo?["voteOption"] as? VoteResponseEntity
            if !(voteOption?.response.isEmpty ?? true) {
                let voteProcessViewController = VoteProcessDIContainer(voteResponseEntity: voteOption).makeViewController()
                topViewController?.navigationController?.pushViewController(voteProcessViewController, animated: true)
            } else {
                let voteBeginViewController = DependencyContainer.shared.injector.resolve(VoteBeginViewController.self)
                topViewController?.navigationController?.pushViewController(voteBeginViewController, animated: true)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .showVoteEffectViewController, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            let topViewController = self.window?.rootViewController?.topMostViewController()
            let voteEffectViewController = DependencyContainer.shared.injector.resolve(VoteEffectViewController.self)
            topViewController?.navigationController?.pushViewController(voteEffectViewController, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .showVoteInventoryViewController, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            let topViewController = self.window?.rootViewController?.topMostViewController()
            let voteInventoryViewController = DependencyContainer.shared.injector.resolve(VoteInventoryViewController.self)
            topViewController?.navigationController?.pushViewController(voteInventoryViewController, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .showVoteCompleteViewController, object: nil, queue: .main) { [weak self] notification in
            guard let self,
                  let isCurrnetDate = notification.userInfo?["isCurrnetDate"] as? Bool else { return }
            let topViewController = self.window?.rootViewController?.topMostViewController()
            
            
            if isCurrnetDate {
                let voteCompleteViewController = DependencyContainer.shared.injector.resolve(VoteCompleteViewController.self)
                topViewController?.navigationController?.pushViewController(voteCompleteViewController, animated: true)
            } else {
                let voteEffectViewController = DependencyContainer.shared.injector.resolve(VoteEffectViewController.self)
                topViewController?.navigationController?.pushViewController(voteEffectViewController, animated: true)
            }
            
        }
    }
    
}


extension SceneDelegate {
    private func setupMainViewController() {
        let voteMainViewController = DependencyContainer.shared.injector.resolve(VoteMainViewController.self)
        let voteNavigationContoller = UINavigationController(rootViewController: voteMainViewController)
        
        let messageMainViewController = DependencyContainer.shared.injector.resolve(MessageMainViewController.self)
        let messageNavigationContoller = UINavigationController(rootViewController: messageMainViewController)
        
        
        let allMainViewController = DependencyContainer.shared.injector.resolve(AllMainViewController.self)
        let allNavigationContoller = UINavigationController(rootViewController: allMainViewController)
    
        let tabbarcontroller = WSTabBarViewController()
        tabbarcontroller.viewControllers = [voteNavigationContoller,messageNavigationContoller, allNavigationContoller]
        window?.rootViewController = tabbarcontroller
    }
}
