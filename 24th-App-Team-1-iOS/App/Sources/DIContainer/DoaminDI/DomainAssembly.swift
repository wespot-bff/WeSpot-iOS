//
//  DomainAssembly.swift
//  wespot
//
//  Created by Kim dohyun on 7/23/24.
//

import Foundation
import VoteDomain

import Swinject

struct DomainAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FetchVoteOptionsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(VoteRepositoryProtocol.self)!
            return FetchVoteOptionsUseCase(voteRepository: repository)
        }
    }
}