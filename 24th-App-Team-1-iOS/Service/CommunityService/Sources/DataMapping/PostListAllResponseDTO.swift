//
//  PostListAllResponseDTO.swift
//  CommunityService
//
//  Created by 김도현 on 7/31/25.
//

import CommunityDomain



enum PostElementDTO: Decodable {
    case postItem(PostItemDTO)
    case voteComponent(VoteComponentDTO)
    case hotPost(HotPostItemDTO)

    private enum CodingKeys: String, CodingKey { case type }

    private enum ElementType: String, Decodable {
        case PostItem
        case voteItem = "VoteItem"
        case HotPostItem
        
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(ElementType.self, forKey: .type)
        switch rawType {
        case .PostItem:
            let item = try PostItemDTO(from: decoder)
            self = .postItem(item)
        case .voteItem:
             let vote = try VoteComponentDTO(from: decoder)
            self = .voteComponent(vote)
        case .HotPostItem:
            let dto = try HotPostItemDTO(from: decoder)
            self = .hotPost(dto)
        }
    }
}

public struct HotPostItemDTO: Decodable {
    let id: Int
    let type: String
    let content: HotPostContentDTO

    public func toDomain() -> HotPostItem {
        return HotPostItem(
            id: id,
            titleIconURL: content.title.icon.url,
            titleText: content.title.text.toDomain(),
            innerPosts: content.posts.compactMap { $0.toDomain()}
        )
    }

    struct HotPostContentDTO: Decodable {
        struct TitleDTO: Decodable {
            struct IconWrapperDTO: Decodable {
                let url: String
                let color: StyledTextDTO.ColorDTO
            }
            let icon: IconWrapperDTO
            let text: StyledTextDTO
        }

        let title: TitleDTO
        let posts: [HotPostInnerDTO]
    }

    public struct HotPostInnerDTO: Decodable {
        struct HeaderSectionDTO: Decodable {
            let profileImage: ImageDTO
            let nickname: StyledTextDTO
        }

        struct InfoSectionDTO: Decodable {
            let title: StyledTextDTO?
            let description: StyledTextDTO?
        }

        let headerSection: HeaderSectionDTO
        let infoSection: InfoSectionDTO?
        let createdAt: StyledTextDTO
        let gradation: GradationDTO

        func toDomain() -> HotPostInner? {
            guard
              let info = infoSection,
              let title = info.title,
              let description = info.description
            else { return nil }
            
            return HotPostInner(
                profileImageURL: headerSection.profileImage.url,
                profileImageSizeWidth: headerSection.profileImage.width ?? 0,
                profileImageSizeHeight: headerSection.profileImage.height ?? 0,
                nickname: headerSection.nickname.toDomain(),
                title: title.toDomain(),
                description: description.toDomain(),
                createdAt: createdAt.toDomain(),
                gradationStart: gradation.startColor.value,
                gradationEnd: gradation.endColor.value,
                gradationAngle: gradation.angle
            )
        }

        struct GradationDTO: Decodable {
            let startColor: StyledTextDTO.ColorDTO
            let endColor: StyledTextDTO.ColorDTO
            let angle: Int
        }
    }
}





struct VoteComponentDTO: Decodable {
    let id: Int
    let type: String
    let content: VoteContentDTO
}

struct VoteContentDTO: Decodable {
    let badge: BadgeDTO
    let text: StyledTextDTO
    let actionIcon: ActionIconDTO
    let gradation: GradationDTO
}


struct BadgeDTO: Decodable {
    let backgroundColor: ColorValueDTO
    let text: StyledTextDTO
}

struct ActionIconDTO: Decodable {
    let backgroundColor: ColorValueDTO
    let icon: IconDTO
}

struct GradationDTO: Decodable {
    let startColor: ColorValueDTO
    let endColor: ColorValueDTO
    let angle: Int
}

struct ColorValueDTO: Decodable {
    let value: String
    let type: String
}



extension PostElementDTO {
    func toDomain() -> PostListElement {
        switch self {
        case .postItem(let dto):
            return .post(dto.toDomain())
        case .voteComponent(let dto):
            return .vote(dto.toDomain())
        case .hotPost(let dto):
            return .hotPost(dto.toDomain())
        }
    }
}


extension VoteComponentDTO {
    func toDomain() -> VoteComponent {
        .init(
            id: id,
            badge: content.badge.text.toDomain(),
            text: content.text.toDomain(),
            actionIconURL: content.actionIcon.icon.url,
            gradientStart: content.gradation.startColor.value,
            gradientEnd: content.gradation.endColor.value,
            gradientAngle: content.gradation.angle
        )
    }
}
