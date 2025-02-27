//
//  ProfileOnboardingEntity.swift
//  CommonDomain
//
//  Created by 김도현 on 2/25/25.
//

import Foundation


public struct ProfileOnboardingEntity: Identifiable {
    public let id: Int
    public let name: String
    public let components: [ProfileOnboardingComponentsEntity]
    
    public init(id: Int, name: String, components: [ProfileOnboardingComponentsEntity]) {
        self.id = id
        self.name = name
        self.components = components
    }
}


public struct ProfileOnboardingComponentsEntity {
    public let componentType: String
    public let titleText: String?
    public let imageURL: String?
    public let width: Int?
    public let height: Int?
    public let buttonComponentList: [ProfileButtonComponentListEntity]?
    
    public init(
        componentType: String,
        titleText: String?,
        imageURL: String?,
        width: Int?,
        height: Int?,
        buttonComponentList: [ProfileButtonComponentListEntity]?
    ) {
        self.componentType = componentType
        self.titleText = titleText
        self.imageURL = imageURL
        self.width = width
        self.height = height
        self.buttonComponentList = buttonComponentList
    }
}

public struct ProfileButtonComponentListEntity {
    public let text: String
    public let textColor: String
    public let pressColor: String
    public let buttonColor: String
    public let onClickAction: ProfileButtonClickActionEntity
    
    public init(
        text: String,
        textColor: String,
        pressColor: String,
        buttonColor: String,
        onClickAction: ProfileButtonClickActionEntity
    ) {
        self.text = text
        self.textColor = textColor
        self.pressColor = pressColor
        self.buttonColor = buttonColor
        self.onClickAction = onClickAction
    }
}


public struct ProfileButtonClickActionEntity {
    public let type: String?
    public let deepLink: String?
    
    public init(type: String?, deepLink: String?) {
        self.type = type
        self.deepLink = deepLink
    }
}
