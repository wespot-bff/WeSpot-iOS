//
//  SplashPresentationAssembly.swift
//  wespot
//
//  Created by 김도현 on 11/29/24.
//

import Foundation

import LoginFeature
import SplashFeature
import CommonDomain
import Swinject

/// Splash DIContainer
struct SplashPresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(SplashViewReactor.self) { (resolver, accessToken: String?) in
            let fetchAppVersionUseCase = resolver.resolve(FetchAppVersionItemUseCaseProtocol.self)!
            return SplashViewReactor(fetchAppVersionUseCase: fetchAppVersionUseCase, accessToken: accessToken)
        }
        
        container.register(SplashViewController.self) { (resolver, accessToken: String?) in
            let reactor = resolver.resolve(SplashViewReactor.self, argument: accessToken)!
            return SplashViewController(reactor: reactor)
        }
    }
    
}
