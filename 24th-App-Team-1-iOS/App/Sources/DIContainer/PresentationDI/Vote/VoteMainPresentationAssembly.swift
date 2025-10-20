//
//  VoteMainPresentationAssembly.swift
//  wespot
//
//  Created by Kim dohyun on 7/27/24.
//

import Foundation
import VoteFeature
import VoteDomain
import CommonDomain

import Swinject


/// VoteMain DIContainer
struct VoteMainPresentationAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(TermsViewReactor.self) { resolver in
            let updateAllowPolicyUseCase = resolver.resolve(UpdateAllowPolicyUseCaseProtocol.self)!
            return TermsViewReactor(updateAllowPolicyUseCase: updateAllowPolicyUseCase)
        }
        
        container.register(TermsViewController.self) { resolver in
            let reactor = resolver.resolve(TermsViewReactor.self)!
            
            return TermsViewController(reactor: reactor)
        }
        
        
        container.register(VoteMainViewReactor.self) { resolver in
            let fetchMinorAppVersionUseCase = resolver.resolve(FetchMinorAppVersionUseCaseProtocol.self)!
            let fetchRestrictionsUseCaseProtocol = resolver.resolve(FetchRestrictionsUseCaseProtocol.self)!
            return VoteMainViewReactor(fetchMinorAppVersionUseCase: fetchMinorAppVersionUseCase, fetchRestrictionsUseCase: fetchRestrictionsUseCaseProtocol)
        }
        
        container.register(VoteMainViewController.self) { resolver in
            let reactor = resolver.resolve(VoteMainViewReactor.self)!
        
            return VoteMainViewController(reactor: reactor)
        }
    }
}


/// VoteHome DIContainer
struct VoteHomePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(VoteHomeViewReactor.self) { resolver in
            let fetchVoteOptionsUseCase = resolver.resolve(FetchVoteOptionsUseCaseProtocol.self)!
            return VoteHomeViewReactor(fetchVoteOptionUseCase: fetchVoteOptionsUseCase)
        }
        
        container.register(VoteHomeViewController.self) { resovler in
            let reactor = resovler.resolve(VoteHomeViewReactor.self)!
            
            return VoteHomeViewController(reactor: reactor)
        }
    }
    
    
}
/// VotePage DIContainer
struct VotePagePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(VotePageViewReactor.self) { _ in
            return VotePageViewReactor()
        }
        
        container.register(VotePageViewController.self) { resolver in
            let reactor = resolver.resolve(VotePageViewReactor.self)!
            
            return VotePageViewController(reactor: reactor)
        }
    }
}

/// VoteResult DIContainer
struct VoteResultPresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(VoteResultViewReactor.self) { resolver in
            let fetchWinnerUseCase = resolver.resolve(FetchWinnerVoteOptionsUseCaseProtocol.self)!
            return VoteResultViewReactor(fetchWinnerVoteOptionsUseCase: fetchWinnerUseCase)
        }
        
        container.register(VoteResultViewController.self) { resolver in
            let reactor = resolver.resolve(VoteResultViewReactor.self)!
            
            return VoteResultViewController(reactor: reactor)
        }
        
    }
}
