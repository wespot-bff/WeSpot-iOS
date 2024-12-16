//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 김도현 on 12/3/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers


let splashService = Project.makeProject(
    module: .service(.SplashService),
    targets: [
        .service(module: .SplashService, dependencies: [
            .shared(module: .ThirdPartyLib),
            .core(module: .Util)
        ])
        
    ])
