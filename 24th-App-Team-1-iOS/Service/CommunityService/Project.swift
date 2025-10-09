//
//  Project.swift
//  Manifests
//
//  Created by 김도현 on 7/26/25.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers


let communityService = Project.makeProject(
    module: .service(.CommunityService),
    targets: [
        .service(
            module: .CommunityService,
            dependencies: [
                .domain(module: .CommunityDomain),
                .core(module: .Networking),
                .shared(module: .ThirdPartyLib),
                .SPM.tca
            ]
        )
    ]
)
