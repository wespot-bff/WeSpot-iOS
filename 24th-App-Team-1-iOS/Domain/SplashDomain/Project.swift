//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도현 on 12/3/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers


let splashDomain = Project.makeProject(
    module: .domain(.SplashDomain),
    targets: [
        .domain(module: .SplashDomain, dependencies: [
            .shared(module: .ThirdPartyLib),
            .domain(module: .CommonDomain)
        ])
    ]
)
