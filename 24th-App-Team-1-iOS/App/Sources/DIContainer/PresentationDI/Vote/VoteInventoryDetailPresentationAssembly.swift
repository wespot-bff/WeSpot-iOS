//
//  VoteInventoryDetailPresentationAssembly.swift
//  wespot
//
//  Created by Kim dohyun on 8/10/24.
//

import Foundation
import VoteFeature
import VoteDomain

import Swinject

struct VoteInventoryDetailPresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(VoteInventoryDetailViewReactor.self) { (resolver, voteId: Int) in
            let fetchIndividualUseCase = resolver.resolve(FetchIndividualItemUseCaseProtocol.self)!
            
            return VoteInventoryDetailViewReactor(
                fetchIndividualItemUseCase: fetchIndividualUseCase,
                voteId: voteId
            )
        }
        
        container.register(VoteInventoryDetailViewController.self) { (resolver, voteId: Int) in
            let reactor = resolver.resolve(VoteInventoryDetailViewReactor.self, argument: voteId)!
            
            return VoteInventoryDetailViewController(reactor: reactor)
        }
    }
}
