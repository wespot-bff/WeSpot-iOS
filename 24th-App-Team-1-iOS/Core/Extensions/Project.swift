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
        module: .core(.Extensions),
        targets: [
            .core(module: .Extensions, dependencies: [
                .shared(module: .ThirdPartyLib)
            ])
        ]
    )
