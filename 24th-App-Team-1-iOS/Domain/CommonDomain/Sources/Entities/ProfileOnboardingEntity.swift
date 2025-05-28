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
    public let data: [ProfileOnbardingInfoEntity]
    
    public init(id: Int, name: String, data: [ProfileOnbardingInfoEntity]) {
        self.id = id
        self.name = name
        self.data = data
    }
}

public struct ProfileOnbardingInfoEntity {
    public let type: String
    public let components: [ProfileOnboardingComponentEntity]
    
    public init(type: String, components: [ProfileOnboardingComponentEntity]) {
        self.type = type
        self.components = components
    }
}


public struct ProfileOnboardingComponentEntity {
    public let componentType: String
    public let content: ProfileOnboardingContentEntity
    
    public init(componentType: String, content: ProfileOnboardingContentEntity) {
        self.componentType = componentType
        self.content = content
    }
}

public struct ProfileOnboardingContentEntity {
    public let richText: ProfileOnboardingRichContentEntity?
    public let url: String?
    public let icons: [ProfileOnboardingIconsContentEntity]?
    public let paddings: ProfilePaddingsEntity?
    public let buttons: [ProfileButtonsEntity]?
    
    public init(
        richText: ProfileOnboardingRichContentEntity?,
        url: String?,
        icons: [ProfileOnboardingIconsContentEntity]?,
        paddings: ProfilePaddingsEntity?,
        buttons: [ProfileButtonsEntity]?
    ) {
        self.richText = richText
        self.url = url
        self.icons = icons
        self.paddings = paddings
        self.buttons = buttons
    }
}

public struct ProfileButtonsEntity {
    public let richText: ProfileOnboardingRichContentEntity
    public let buttonColor: String
    public let pressColor: String
    public let onClickAction: ProfileButtonActionEntity
    public let padding: ProfilePaddingsEntity?
    
    public init(
        richText: ProfileOnboardingRichContentEntity,
        buttonColor: String,
        pressColor: String,
        onClickAction: ProfileButtonActionEntity,
        padding: ProfilePaddingsEntity?
    ) {
        self.richText = richText
        self.buttonColor = buttonColor
        self.pressColor = pressColor
        self.onClickAction = onClickAction
        self.padding = padding
    }
}

public struct ProfileButtonActionEntity {
    public let type: String
    public let deepLink: String?
    
    public init(type: String, deepLink: String?) {
        self.type = type
        self.deepLink = deepLink
    }
}


public struct ProfilePaddingsEntity {
    public let start: Int?
    public let end: Int?
    public let bottom: Int?
    
    public init(
        start: Int?,
        end: Int?,
        bottom: Int?
    ) {
        self.start = start
        self.end = end
        self.bottom = bottom
    }
}

public struct ProfileOnboardingRichContentEntity {
    public let text: String
    public let color: String
    public let fontSize: Int
    public let align: String
    public let fontWeight: String
    
    public init(
        text: String,
        color: String,
        fontSize: Int,
        align: String,
        fontWeight: String
    ) {
        self.text = text
        self.color = color
        self.fontSize = fontSize
        self.align = align
        self.fontWeight = fontWeight
    }
}

public struct ProfileOnboardingIconsContentEntity {
    public let url: String
    public let width: Int
    public let height: Int
    public let onClickAction: ProfileOnboardingActionEntity
    
    public init(
        url: String,
        width: Int,
        height: Int,
        onClickAction: ProfileOnboardingActionEntity
    ) {
        self.url = url
        self.width = width
        self.height = height
        self.onClickAction = onClickAction
    }
    
}


public struct ProfileOnboardingActionEntity {
    public let type: String
    public let deepLink: String?
    
    public init(type: String, deepLink: String?) {
        self.type = type
        self.deepLink = deepLink
    }
}


public extension ProfileOnboardingEntity {
    func component(
        in sectionType: String,
        ofType componentType: String,
        at index: Int = 0
    ) -> ProfileOnboardingComponentEntity? {
        guard let section = data.first(where: { $0.type == sectionType }) else { return nil }
        
        let filtered = section.components
            .filter { $0.componentType == componentType }
        guard index >= 0, index < filtered.count else {
            return nil
        }
        return filtered[index]
    }

}
