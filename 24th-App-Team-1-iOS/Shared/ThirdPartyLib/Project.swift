//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim dohyun on 6/12/24.
//

@preconcurrency import ProjectDescription
import ProjectDescriptionHelpers

let project = Project
    .makeProject(
        module: .shared(.ThirdPartyLib),
        targets: [
            .share(module: .ThirdPartyLib, dependencies: [
                .SPM.rxSwift,
                .SPM.rxCocoa,
                .SPM.reactorKit,
                .SPM.rxDataSources,
                .SPM.snapKit,
                .SPM.then,
                .SPM.alamofire,
                .SPM.swinject,
                .SPM.kingfisher,
                .SPM.kakaoSDKAuth,
                .SPM.rxKakaoSDKAuth,
                .SPM.kakaoSDKUser,
                .SPM.rxKakaoSDKUser,
                .SPM.lottie,
                .SPM.keychain
            ])
        ]
    )
