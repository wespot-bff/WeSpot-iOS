//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim dohyun on 6/12/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers


let project = Project.makeProject(
    module: .core(.Util),
    targets: [
        .core(module: .Util, dependencies: [
            .shared(module: .ThirdPartyLib),
            .shared(module: .DesignSystem),
            .domain(module: .CommonDomain)
        ])
    ]
)
