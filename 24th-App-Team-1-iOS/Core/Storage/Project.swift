//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by eunseou on 6/12/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let project = Project
    .makeProject(
        module: .core(.Storage),
        targets: [
            .core(module: .Storage, dependencies: [
                .shared(module: .ThirdPartyLib),
                .domain(module: .LoginDomain),
                .domain(module: .VoteDomain),
                .core(module: .Extensions)
            ])
        ]
    )
