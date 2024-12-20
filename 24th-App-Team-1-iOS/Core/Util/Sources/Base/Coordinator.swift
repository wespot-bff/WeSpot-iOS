//
//  Coordinator.swift
//  Util
//
//  Created by 김도현 on 12/20/24.
//

import UIKit

import Swinject

/// 공통으로 사용하는 Coordinator Protocol 입니다.
public protocol Coordinator {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
}
