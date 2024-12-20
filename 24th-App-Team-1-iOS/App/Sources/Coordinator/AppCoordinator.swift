//
//  AppCoordinator.swift
//  wespot
//
//  Created by 김도현 on 12/20/24.
//

import UIKit

import Util
import LoginFeature

/// SceneDelegate에 호출되는 화면 전환 메서드의 청사진 입니다.
public protocol AppCoordinatorProtocol {
    func toLogin()
    func toMain()
}


final class AppCoordinator: AppCoordinatorProtocol, Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator]
    
    public init(navigationController: UINavigationController, childCoordinators: [any Coordinator]) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }
    
    
    //TODO: login, Main 화면 전환 로직 추가
    public func toLogin() {
        let signInReactor = SignInDIContainer().makeReactor()
        let signInViewController = SignInDIContainer().makeViewController()
        signInReactor.signInCoordinator = self

        navigationController.pushViewController(signInViewController, animated: true)
    }
    
    public func toMain() {
        
    }
    
}

