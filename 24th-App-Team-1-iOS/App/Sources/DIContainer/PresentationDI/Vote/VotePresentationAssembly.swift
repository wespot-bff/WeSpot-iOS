//
//  VotePresentationAssembly.swift
//  wespot
//
//  Created by Kim dohyun on 7/23/24.
//

import Foundation
import VoteFeature
import VoteDomain
import CommonDomain

import Swinject


struct VotePresentationAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(VoteBeginViewReactor.self) { resolver in
            let fetchUserProfileUseCase = resolver.resolve(FetchUserProfileUseCaseProtocol.self)!
            return VoteBeginViewReactor(fetchUserProfileUseCase: fetchUserProfileUseCase)
        }
        
        container.register(VoteBeginViewController.self) { resolver in
            let reactor = resolver.resolve(VoteBeginViewReactor.self)!
            
            return VoteBeginViewController(reactor: reactor)
        }
    }
}
