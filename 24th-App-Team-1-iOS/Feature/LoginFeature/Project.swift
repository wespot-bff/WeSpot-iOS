//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by eunseou on 6/11/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let loginFeature = Project.makeProject(
    module: .feature(.LoginFeature),
    targets: [
        .feature(module: .LoginFeature, dependencies: [
            .domain(module: .CommonDomain),
            .service(module: .CommonService),
            .domain(module: .LoginDomain),
            .service(module: .LoginService),
            .shared(module: .ThirdPartyLib),
            .shared(module: .DesignSystem),
            .core(module: .Util),
            .core(module: .Storage)
        ], product: .staticFramework)
    ]
)
