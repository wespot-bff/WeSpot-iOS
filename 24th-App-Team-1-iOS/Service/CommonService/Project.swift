//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by eunseou on 8/3/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let loginService = Project.makeProject(
    module: .service(.CommonService),
    targets: [
        .service(module: .CommonService, dependencies: [
            .core(module: .Networking),
            .domain(module: .CommonDomain),
            .service(module: .CommunityService),
            .shared(module: .ThirdPartyLib),
            .core(module: .Util),
            .SPM.firebaseRemoteConfig
        ],product: .staticFramework)
    ]
)
