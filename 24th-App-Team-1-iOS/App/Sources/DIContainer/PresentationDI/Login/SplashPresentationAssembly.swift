//
//  SplashPresentationAssembly.swift
//  wespot
//
//  Created by 김도현 on 11/29/24.
//

import Foundation

import LoginFeature
import SplashFeature
import SplashDomain
import CommonDomain
import Swinject

/// Splash DIContainer
struct SplashPresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(SplashViewReactor.self) { (resolver, accessToken: String?) in
            let fetchMajorAppVersionUseCase = resolver.resolve(FetchMajorAppVersionUseCaseProtocol.self)!
            return SplashViewReactor(fetchMajorAppVersionUseCase: fetchMajorAppVersionUseCase, accessToken: accessToken)
        }
        
        container.register(SplashViewController.self) { (resolver, accessToken: String?) in
            let reactor = resolver.resolve(SplashViewReactor.self, argument: accessToken)!
            return SplashViewController(reactor: reactor)
        }
        
        container.register(ProfileOnboardingView.self) { resolver in
            let viewModel = resolver.resolve(ProfileOnboardingViewModel.self)!
            return ProfileOnboardingView(viewModel: viewModel)
        }
        
        container.register(ProfileOnboardingViewModel.self) { _ in
            return ProfileOnboardingViewModel()
        }
    }
    
}
