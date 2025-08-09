//
//  Project.swift
//  Manifests
//
//  Created by 김도현 on 7/26/25.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let communityDomain = Project.makeProject(
    module: .domain(.CommunityDomain),
    targets: [
        .domain(
            module: .CommunityDomain,
            dependencies: [
                .shared(module: .ThirdPartyLib)
            ]
        )
        
    ]
)
