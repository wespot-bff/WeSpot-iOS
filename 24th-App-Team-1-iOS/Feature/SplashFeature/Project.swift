//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도현 on 12/3/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let splashFeature = Project.makeProject(
    module: .feature(.SplashFeature),
    targets: [
        .feature(module: .SplashFeature,
                 dependencies: [
                    .core(module: .Util),
                    .service(module: .SplashService),
                    .domain(module: .SplashDomain),
                    .shared(module: .ThirdPartyLib),
                    .shared(module: .DesignSystem)
                 ])
    ]
)
