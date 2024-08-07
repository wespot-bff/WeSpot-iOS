//
//  InfoPlist+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by eunseou on 6/11/24.
//

import ProjectDescription

extension InfoPlist {
    
    public static var `default`: Self = {
        return .extendingDefault(with: [
            "BASE_URL": .string("https://74a7cbb8-7129-42f6-9958-b1658e7c1882.mock.pstmn.io/api/v1")
        ])
    }()
    
    static func makeInfoPlist() -> Self {
        
        
        var basePlist: [String: Plist.Value] = [
            "CFBundleDisplayName": .string("wespot"),
            "UIUserInterfaceStyle": .string("Dark"),
            "CFBundleShortVersionString": .string("1.0"),
            "CFBundleVersion": .string("1"),
            "UILaunchStoryboardName": .string("LaunchScreen"),
            "UIApplicationSceneManifest": .dictionary([
                "UIApplicationSupportsMultipleScenes": .boolean(false),
                "UISceneConfigurations": [
                    "UIWindowSceneSessionRoleApplication": .array([
                        .dictionary([
                            "UISceneConfigurationName": .string("Default Configuration"),
                            "UISceneDelegateClassName": .string("$(PRODUCT_MODULE_NAME).SceneDelegate")
                        ])
                    ])
                ]
            ]),
            "LSApplicationQueriesSchemes": [
                "kakaokompassauth",
                "kakaolink",
                "kakaoplus"
            ],
            "KAKAO_NATIVE_APP_KEY": .string("${KAKAO_NATIVE_APP_KEY}"),
            "CFBundleURLTypes": .array([
                .dictionary([
                    "CFBundleTypeRole": .string("Editor"),
                    "CFBundleURLSchemes": .array([
                        .string("kakao${KAKAO_NATIVE_APP_KEY}")
                    ])
                ])
            ]),
            "NSAppTransportSecurity": .dictionary([
                "NSAllowsArbitraryLoads": .boolean(false)
            ]),
            "UIAppFonts": .array([
                .string("Pretendard-Regular.otf"),
                .string("Pretendard-Bold.otf"),
                .string("Pretendard-Medium.otf"),
                .string("Pretendard-SemiBold.otf")
            ]),
            "BASE_URL": .string("https://74a7cbb8-7129-42f6-9958-b1658e7c1882.mock.pstmn.io/api/v1"),
            "NSAppleIDUsageDescription": .string("로그인에 Apple ID를 사용합니다."),
            "aps-environment": .string("development") 
        ]
        
        return InfoPlist.extendingDefault(with: basePlist)
    }
}
