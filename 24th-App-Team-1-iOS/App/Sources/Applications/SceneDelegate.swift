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
        
        Task { @MainActor in
            do {
                try await WSVersionManager.shared.versionCheck { isForceUpdate in
                    if isForceUpdate {
                        await MainActor.run {
                            self.handleVersionCheckResult(isForceUpdate: isForceUpdate)
                        }
                    }
                }
            } catch {
                assertionFailure("강제 업데이트 로직 에러 \(error.localizedDescription)")
            }
        }
        
        window = UIWindow(windowScene: scene)
        
        let accessToken = KeychainManager.shared.get(type: .accessToken)
        let refreshToken = KeychainManager.shared.get(type: .refreshToken)
        
        
        if accessToken == nil || refreshToken == nil {
            let signInViewController = DependencyContainer.shared.injector.resolve(SignInViewController.self)
            window?.rootViewController = UINavigationController(rootViewController: signInViewController)
            
        } else {
            setupMainViewController()
        }
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
        
        NotificationCenter.default.addObserver(forName: .showVoteMainViewController, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            setupMainViewController()
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
                let voteProcessViewController = DependencyContainer.shared.injector.resolve(VoteProcessViewController.self, argument: voteOption)
                topViewController?.navigationController?.pushViewController(voteProcessViewController, animated: true)
            } else {
                let voteBeginViewController = DependencyContainer.shared.injector.resolve(VoteBeginViewController.self)
                topViewController?.navigationController?.pushViewController(voteBeginViewController, animated: true)
            }
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
    private func handleVersionCheckResult(isForceUpdate: Bool) {
        if isForceUpdate {
            showUpdateVersionAlert(true)
        }
    }
    
    private func showUpdateVersionAlert(_ isForceUpdate: Bool) {
        guard let topViewController = self.window?.rootViewController?.topMostViewController() else {
            return
        }
        
        WSAlertBuilder(showViewController: topViewController)
            .setAlertType(type: .titleWithMeesage)
            .setButtonType(type: .confirm)
            .setTitle(title: "새로운 버전이 업데이트 되었어요!")
            .setMessage(message: "유저의 의견을 반영하여 사용성을 개선했어요 \n지금 업데이트하고 더 나은 위스팟을 만나보세요")
            .setConfirm(text: "업데이트")
            .action(.confirm) {
                UIApplication.shared.open(WSURLType.appStore.urlString)
            }
            .show()
    }
    
    
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
