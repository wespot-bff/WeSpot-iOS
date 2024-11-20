//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim dohyun on 8/11/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers


let appService = Project.makeProject(
    module: .service(.AllService),
    targets: [
        .service(
            module: .AllService,
            dependencies: [
                .core(module: .Networking),
                .shared(module: .ThirdPartyLib)
            ]
        )
    ]
)
