//
//  SplashPresentationAssembly.swift
//  wespot
//
//  Created by 김도현 on 11/29/24.
//

import Foundation

import LoginFeature
import Swinject

/// Splash DIContainer
struct SplashPresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(SplashViewReactor.self) { (_, accessToken: String?) in
            return SplashViewReactor(accessToken: accessToken)
        }
        
        container.register(SplashViewController.self) { (resolver, accessToken: String?) in
            let reactor = resolver.resolve(SplashViewReactor.self, argument: accessToken)!
            return SplashViewController(reactor: reactor)
        }
    }
    
}
