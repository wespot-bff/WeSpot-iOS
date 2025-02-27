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
    public let components: [ProfileComponentsResponseDTO]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case components = "data"
    }
}

public extension ProfileOnboardingResponseDTO {
    struct ProfileComponentsResponseDTO: Decodable {
        public let componentType: String
        public let titleText: String?
        public let imageURL: String?
        public let width: Int?
        public let height: Int?
        public let buttonComponentList: [ProfileButtonComponentResponseDTO]?
        
        private enum CodingKeys: String, CodingKey {
            case componentType = "type"
            case titleText = "text"
            case imageURL = "url"
            case width
            case height
            case buttonComponentList = "buttonList"
        }
    }
}


public extension ProfileOnboardingResponseDTO.ProfileComponentsResponseDTO {
    struct ProfileButtonComponentResponseDTO: Decodable {
        public let text: String
        public let textColor: String
        public let pressColor: String
        public let buttonColor: String
        public let onClickAction: ProfileButtonClickActionResponseDTO
    }
}

public extension ProfileOnboardingResponseDTO.ProfileComponentsResponseDTO.ProfileButtonComponentResponseDTO {
    struct ProfileButtonClickActionResponseDTO: Decodable {
        public let type: String?
        public let deepLink: String?
    }
}



public extension ProfileOnboardingResponseDTO {
    func toDomain() -> ProfileOnboardingEntity {
        return .init(id: id, name: name, components: components.map { $0.toDomain()} )
    }
}

public extension ProfileOnboardingResponseDTO.ProfileComponentsResponseDTO {
    func toDomain() -> ProfileOnboardingComponentsEntity {
        return .init(componentType: componentType, titleText: titleText, imageURL: imageURL, width: width, height: height, buttonComponentList: buttonComponentList?.compactMap { $0.toDomain()})
    }
}



public extension ProfileOnboardingResponseDTO.ProfileComponentsResponseDTO.ProfileButtonComponentResponseDTO {
    func toDomain() -> ProfileButtonComponentListEntity {
        return .init(text: text, textColor: textColor, pressColor: pressColor, buttonColor: buttonColor, onClickAction: onClickAction.toDomain())
    }
}

public extension ProfileOnboardingResponseDTO.ProfileComponentsResponseDTO.ProfileButtonComponentResponseDTO.ProfileButtonClickActionResponseDTO {
    func toDomain() -> ProfileButtonClickActionEntity {
        return .init(type: type, deepLink: deepLink)
    }
}
