//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by eunseou on 8/3/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let commonDomain = Project.makeProject(
    module: .domain(.CommonDomain),
    targets: [
        .domain(module: .CommonDomain, dependencies: [
            .shared(module: .ThirdPartyLib),
            .core(module: .Storage)
        ], product: .staticFramework)
    ]
)
