//
//  project.swift
//  ProjectDescriptionHelpers
//
//  Created by eunseou on 7/20/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let messageDomain = Project.makeProject(
    module: .domain(.MessageDomain),
    targets: [
        .domain(module: .MessageDomain, dependencies: [
            .shared(module: .ThirdPartyLib)
        ])
    ]
)
