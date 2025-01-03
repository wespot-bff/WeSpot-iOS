//
//  Project.swift
//  DesignSystemManifests
//
//  Created by Kim dohyun on 6/12/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeProject(
    module: .shared(.DesignSystem),
    targets: [
        .share(module: .DesignSystem, dependencies: [
            .shared(module: .ThirdPartyLib),
            .core(module: .Extensions)
        ])
    ],
    resourceSynthesizers: [
        .custom(name: "lottie", parser: .json, extensions: ["lottie"]),
        .custom(name: "JSON", parser: .json, extensions: ["json"]),
        .assets(),
        .fonts(),
    ]
)
