//
//  SignInDIContainer.swift
//  LoginFeature
//
//  Created by 김도현 on 12/20/24.
//

import Foundation

import Util

public final class SignInDIContainer: BaseDIContainer {
    public typealias ViewController = SignInViewController
    public typealias Reactor = SignInViewReactor
    
    public init() { }
    
    public func makeViewController() -> SignInViewController {
        return SignInViewController(reactor: makeReactor())
    }
    
    public func makeReactor() -> SignInViewReactor {
        return SignInViewReactor()
    }
}
