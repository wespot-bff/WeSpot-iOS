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
                .domain(module: .CommunityDomain),
                .service(module: .CommunityService),
                .domain(module: .CommonDomain),
                .shared(module: .DesignSystem),
                .feature(module: .NotificationFeature),
                .core(module: .Util)
            ]
        )
    ]
)

