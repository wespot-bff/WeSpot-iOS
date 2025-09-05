//
//  PostListItemResponseDTO.swift
//  CommunityService
//
//  Created by 김도현 on 7/29/25.
//

import Foundation

import CommunityDomain

public struct PostListResponseDTO: Decodable {
    let data: [PostElementDTO]
    let lastCursorId: Int?
    let hasNext: Bool
    let background: ImageDTO?
    let thumbnail: ImageDTO?
}


public struct PostItemDTO: Decodable {
    let id: Int
    let type: String
    let isMyPost: Bool
    let content: ContentDTO
}


public struct StyledTextDTO: Decodable {
    struct ColorDTO: Decodable { let value: String; let type: String }
    let text: String
    let color: ColorDTO
    let typography: String
    let maxLine: Int
}

public struct ImageDTO: Decodable {
    let url: String
    let width: Int?
    let height: Int?
    
    private enum CodingKeys: String, CodingKey {
        case url, width, height
    }
    
    public init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer().decode(String.self) {
            self.url = single
            self.width = nil
            self.height = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.width = try container.decodeIfPresent(Int.self, forKey: .width)
        self.height = try container.decodeIfPresent(Int.self, forKey: .height)
    }
    
}

public struct ContentDTO: Decodable {
    let category: CategoryDTO?
    let headerSection: HeaderSectionDTO
    let infoSection: InfoSectionDTO
    let contentSection: ContentSectionDTO?
    let footerSection: FooterSectionDTO
    let button: ButtonDTO?
}

public struct CategoryDTO: Decodable {
    let text: StyledTextDTO
    let target: String
    let icon: IconDTO
}

public struct IconDTO: Decodable {
    let url: String
    let color: StyledTextDTO.ColorDTO
}

public struct HeaderSectionDTO: Decodable {
    let profileImage: ImageDTO
    let nickname: StyledTextDTO
    let createdAt: StyledTextDTO
    let category: CategoryDTO?
    let button: ButtonDTO?
}

public struct InfoSectionDTO: Decodable {
    let title: StyledTextDTO?
    let description: StyledTextDTO
    let seeMore: StyledTextDTO
    let maxLine: Int

    private enum CodingKeys: String, CodingKey {
        case title, description, seeMore, maxLine
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.title       = try c.decodeIfPresent(StyledTextDTO.self, forKey: .title)
        self.description = try c.decode(StyledTextDTO.self,  forKey: .description)
        self.seeMore     = try c.decode(StyledTextDTO.self,  forKey: .seeMore)
        self.maxLine     = try c.decode(Int.self,            forKey: .maxLine)
    }
}

public enum ContentSectionDTO: Decodable {
    case images([ImageDTO])
    case none
    
    private enum CodingKeys: String, CodingKey { case type, images }
    private enum SectionType: String, Decodable { case Images }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(SectionType.self, forKey: .type)

        switch rawType {
        case .Images:
            let imgs = try container.decode([ImageDTO].self, forKey: .images)
            self = .images(imgs)
        }
    }
}

public struct FooterSectionDTO: Decodable {
    let reactions: [ReactionDTO]
    let scrap: ScrapDTO
}

public struct ReactionDTO: Decodable {
    let type: String
    let icon: IconDTO
    let count: StyledTextDTO
    let selected: Bool
}

public struct ScrapDTO: Decodable {
    let icon: IconDTO
    let selected: Bool
}

public struct ButtonDTO: Decodable {
    let type: String?
    let action: String?
    
    let icon: IconDTO?
    let text: StyledTextDTO?
    let isSelected: Bool?
    let title: StyledTextDTO?
    
    private enum CodingKeys: String, CodingKey {
        case type, action, icon, text, isSelected, title
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.action = try container.decodeIfPresent(String.self, forKey: .action)
        self.icon = try container.decodeIfPresent(IconDTO.self, forKey: .icon)
        self.text = try container.decodeIfPresent(StyledTextDTO.self, forKey: .text)
        self.isSelected = try container.decodeIfPresent(Bool.self, forKey: .isSelected)
        self.title = try container.decodeIfPresent(StyledTextDTO.self, forKey: .title)
    }
}

extension PostListResponseDTO {
    func toDomain() -> PostListEntity {
        let elements = data.map { $0.toDomain() }
        return PostListEntity(items: elements, lastCursorId: lastCursorId, hasNext: hasNext, thumbnail: thumbnail?.toDomain(), background: background?.toDomain())
    }
}

extension PostItemDTO {
    func toDomain() -> PostItem {
        return PostItem(
            id: id,
            type: PostType(rawValue: type) ?? .postItem,
            content: content.toDomain(),
            isMyPost: isMyPost
        )
    }
}

extension StyledTextDTO {
    func toDomain() -> StyledText {
        return StyledText(
            text: text,
            color: color.value,
            typography: typography,
            maxLine: maxLine
        )
    }
}

extension ImageDTO {
    func toDomain() -> ImageResource {
        return ImageResource(
            url: url,
            size: {
                guard let w = width, let h = height else { return nil }
                return CGSize(width: w, height: h)
            }()
        )
    }
}

extension ContentDTO {
    func toDomain() -> PostContent {
        return PostContent(
            category: category?.toDomain(),
            header: headerSection.toDomain(),
            info: infoSection.toDomain(),
            contentSection: contentSection?.toDomain(),
            footer: footerSection.toDomain(),
            button: button?.toDomain()
        )
    }
}

public struct DetailButtonDTO: Decodable {
    let type: String
    let icon: IconDTO
    let text: StyledTextDTO
    let isSelected: Bool
}


extension CategoryDTO {
    func toDomain() -> CategoryItemEntity {
        return CategoryItemEntity(
            text: text.text,
            textColor: text.color.value,
            typography: text.typography,
            target: target,
            iconURL: icon.url,
            iconColor: icon.color.value
        )
    }
}


extension HeaderSectionDTO {
    func toDomain() -> HeaderEntity {
        return HeaderEntity(
            profileImageURL: profileImage.url,
            profileImageWidth: profileImage.width ?? 0,
            profileImageHeight: profileImage.height ?? 0,
            nickname: nickname.toDomain(),
            createdAt: createdAt.toDomain(),
            category: category?.toDomain(),
            button: button?.toDomain()
        )
    }
}

extension InfoSectionDTO {
    func toDomain() -> InfoSectionEntity {
        return InfoSectionEntity(
            title: title?.toDomain(),
            description: description.toDomain(),
            seeMore: seeMore.toDomain(),
            maxLine: maxLine
        )
    }
}

extension ContentSectionDTO {
    func toDomain() -> ContentSectionEntity {
        switch self {
        case .images(let images):
            return .images(images.map { $0.toDomain() })
        case .none:
            return .images([])
        }
    }
}

extension FooterSectionDTO {
    func toDomain() -> FooterSectionEntity {
        return FooterSectionEntity(
            reactions: reactions.map { $0.toDomain() },
            scrap: scrap.toDomain()
        )
    }
}

extension ReactionDTO {
    func toDomain() -> Reaction {
        return Reaction(
            type: type,
            iconURL: icon.url,
            iconColor: icon.color.value,
            count: count.toDomain(),
            selected: selected
        )
    }
}

extension ScrapDTO {
    func toDomain() -> Scrap {
        return Scrap(
            iconURL: icon.url,
            iconColor: icon.color.value,
            selected: selected
        )
    }
}

extension ButtonDTO {
    func toDomain() -> ButtonEntity {
        return ButtonEntity(
            type: type,
            title: title?.toDomain() ?? text?.toDomain(),
            action: action,
            icon: icon?.toDomain(),
            isSelected: isSelected
        )
    }
}

extension IconDTO {
    func toDomain() -> IconEntity {
        return IconEntity(
            url: url,
            color: color.value
        )
    }
}
