//  Project.swift
//  Manifests

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let communityFeature = Project.makeProject(
    module: .feature(.CommunityFeature),
    targets: [
        .feature(
            module: .CommunityFeature,
            dependencies: [
                .SPM.tca,
                .shared(module: .DesignSystem),
                .core(module: .Util)
            ]
        )
    ]
)
