//
//  ProfileOnboardingResponseDTO.swift
//  CommonService
//
//  Created by 김도현 on 2/25/25.
//

import Foundation

import CommonDomain


public struct ProfileOnboardingResponseDTO: Decodable {
    public let id: Int
    public let name: String
    public let data: [ProfileOnboardingInfoResponseDTO]
    
}


public extension ProfileOnboardingResponseDTO {
    struct ProfileOnboardingInfoResponseDTO: Decodable {
        public let type: String
        public let components: [ProfileOnboardingComponentResponseDTO]
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO {
    struct ProfileOnboardingComponentResponseDTO: Decodable {
        public let componentType: String
        public let content: ProfileOnboardingContentResponseDTO
        
        private enum CodingKeys: String, CodingKey {
            case componentType = "type"
            case content
        }
    }
}


public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO {
    struct ProfileOnboardingContentResponseDTO: Decodable {
        public let url: String?
        public let richText: ProfileOnboardingRichTextResponseDTO?
        public let icons: [ProfileOnboardingIconsResponseDTO]?
        public let paddings: ProfileOnboardingPaddingResponseDTO?
        public let buttons: [ProfileOnboardingButtonResponseDTO]?
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO {
    struct ProfileOnboardingButtonResponseDTO: Decodable {
        public let richText: ProfileOnboardingRichTextResponseDTO
        public let buttonColor: String
        public let pressColor: String
        public let onClickAction: ProfileOnbardingButtonActionResponseDTO
        public let paddings: ProfileOnboardingPaddingResponseDTO?
    }
    
    struct ProfileOnboardingRichTextResponseDTO: Decodable {
        public let text: String
        public let color: String
        public let fontSize: Int
        public let align: String
        public let fontWeight: String
    }
    
    struct ProfileOnboardingIconsResponseDTO: Decodable {
        public let url: String
        public let width: Int
        public let height: Int
        public let onClickAction: ProfileOnbardingActionResponseDTO
    }
    
    struct ProfileOnboardingPaddingResponseDTO: Decodable {
        public let start: Int?
        public let end: Int?
        public let bottom: Int?
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO {
    struct ProfileOnbardingButtonActionResponseDTO: Decodable {
        public let type: String
        public let deepLink: String?
    }
}


public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO.ProfileOnboardingIconsResponseDTO {
    struct ProfileOnbardingActionResponseDTO: Decodable {
        public let type: String
        public let deepLink: String?
    }
}

public extension ProfileOnboardingResponseDTO {
    func toDomain() -> ProfileOnboardingEntity {
        return .init(id: id, name: name, data: data.map { $0.toDomain() })
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO {
    func toDomain() -> ProfileOnbardingInfoEntity {
        return .init(type: type, components: components.map { $0.toDomain() })
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO {
    func toDomain() -> ProfileOnboardingComponentEntity {
        return .init(componentType: componentType, content: content.toDomain())
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO {
    func toDomain() -> ProfileOnboardingContentEntity {
        return .init(
            richText: richText?.toDomain(),
            url: url,
            icons: icons?.compactMap { $0.toDomain()},
            paddings: paddings?.toDomain(),
            buttons: buttons?.map { $0.toDomain() }
        )
    }
}


public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO.ProfileOnboardingButtonResponseDTO {
    func toDomain() -> ProfileButtonsEntity {
        return .init(
            richText: richText.toDomain(),
            buttonColor: buttonColor,
            pressColor: pressColor,
            onClickAction: onClickAction.toDomain(),
            padding: paddings?.toDomain()
        )
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO.ProfileOnbardingButtonActionResponseDTO {
    func toDomain() -> ProfileButtonActionEntity {
        return .init(type: type, deepLink: deepLink)
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO.ProfileOnboardingPaddingResponseDTO {
    func toDomain() -> ProfilePaddingsEntity {
        return .init(start: start, end: end, bottom: bottom)
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO.ProfileOnboardingRichTextResponseDTO {
    func toDomain() -> ProfileOnboardingRichContentEntity {
        return .init(
            text: text,
            color: color,
            fontSize: fontSize,
            align: align,
            fontWeight: fontWeight
        )
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO.ProfileOnboardingIconsResponseDTO {
    func toDomain() -> ProfileOnboardingIconsContentEntity {
        return .init(
            url: url,
            width: width,
            height: height,
            onClickAction: onClickAction.toDomain()
        )
    }
}

public extension ProfileOnboardingResponseDTO.ProfileOnboardingInfoResponseDTO.ProfileOnboardingComponentResponseDTO.ProfileOnboardingContentResponseDTO.ProfileOnboardingIconsResponseDTO.ProfileOnbardingActionResponseDTO {
    func toDomain() -> ProfileOnboardingActionEntity {
        return .init(type: type, deepLink: deepLink)
    }
}
