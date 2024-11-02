//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim dohyun on 7/22/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let voteService = Project.makeProject(
    module: .service(.VoteService),
    targets: [
        .service(
            module: .VoteService,
            dependencies: [
                .core(module: .Networking),
                .shared(module: .ThirdPartyLib)
            ]
        )
    ]
)


