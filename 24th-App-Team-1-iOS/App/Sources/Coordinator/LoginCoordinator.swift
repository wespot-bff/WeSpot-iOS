//
//  LoginCoordinator.swift
//  wespot
//
//  Created by 김도현 on 12/20/24.
//

import UIKit

import Util
import LoginFeature

/// Login화면에서 호출되는 화면 전환 메서드의 청사진 입니다.
public protocol LoginCoordinatorProtocol {
    
}

public final class LoginCoordinator: LoginCoordinatorProtocol, Coordinator {
    public var navigationController: UINavigationController
    public var childCoordinators: [any Coordinator]
    
    public init(navigationController: UINavigationController, childCoordinators: [any Coordinator]) {
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }
}
