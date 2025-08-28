//
//  PostListEntity.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/30/25.
//
import Foundation

public struct PostLocalOverride: Equatable {
    public var isLiked: Bool?
    public var likeCountDelta: Int
    public var isScrapped: Bool?
    public var isNotified: Bool?
    
    public init(
        isLiked: Bool? = nil,
        likeCountDelta: Int,
        isScrapped: Bool? = nil,
        isNotified: Bool? = nil) {
        self.isLiked = isLiked
        self.likeCountDelta = likeCountDelta
        self.isScrapped = isScrapped
        self.isNotified = isNotified
    }
}


public enum FetchAllListEntity: Equatable, Identifiable {
    case post(PostItem)
    case vote(VoteComponent)

    public var id: String {
        switch self {
        case .post(let item): return "post-\(item.id)"
        case .vote(let vote): return "vote-\(vote.id)"
        }
    }
}

// VoteComponent 도메인
public struct VoteComponent: Equatable {
    public let id: Int
    public let badge: StyledText
    public let text: StyledText
    public let actionIconURL: String
    public let gradientStart: String
    public let gradientEnd: String
    public let gradientAngle: Int
    
    public init(id: Int, badge: StyledText, text: StyledText, actionIconURL: String, gradientStart: String, gradientEnd: String, gradientAngle: Int) {
        self.id = id
        self.badge = badge
        self.text = text
        self.actionIconURL = actionIconURL
        self.gradientStart = gradientStart
        self.gradientEnd = gradientEnd
        self.gradientAngle = gradientAngle
    }
}
public enum PostListElement: Equatable, Identifiable {
    case post(PostItem)
    case vote(VoteComponent)
    case hotPost(HotPostItem)

    public var id: String {
        switch self {
        case .post(let p): return "post-\(p.id)"
        case .vote(let v): return "vote-\(v.id)"
        case .hotPost(let h): return "hotPost-\(h.id)"
        }
    }
}

public struct HotPostItem: Identifiable, Equatable {
    public let id: Int
    public let titleIconURL: String
    public let titleText: StyledText
    public let innerPosts: [HotPostInner?]
    
    public init(id: Int, titleIconURL: String, titleText: StyledText, innerPosts: [HotPostInner?]) {
        self.id = id
        self.titleIconURL = titleIconURL
        self.titleText = titleText
        self.innerPosts = innerPosts
    }
}


public struct HotPostInner: Identifiable ,Equatable {
    public let id: String
    public let profileImageURL: String
    public let profileImageSizeWidth: Int?
    public let profileImageSizeHeight: Int?
    public let nickname: StyledText
    public let title: StyledText?
    public let description: StyledText
    public let createdAt: StyledText
    public let gradationStart: String
    public let gradationEnd: String
    public let gradationAngle: Int
    
    public init(
        id: String = UUID().uuidString,
        profileImageURL: String,
        profileImageSizeWidth: Int?,
        profileImageSizeHeight: Int?,
        nickname: StyledText,
        title: StyledText?,
        description: StyledText,
        createdAt: StyledText,
        gradationStart: String,
        gradationEnd: String,
        gradationAngle: Int
    ) {
        self.id = id
        self.profileImageURL = profileImageURL
        self.profileImageSizeWidth = profileImageSizeWidth
        self.profileImageSizeHeight = profileImageSizeHeight
        self.nickname = nickname
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.gradationStart = gradationStart
        self.gradationEnd = gradationEnd
        self.gradationAngle = gradationAngle
    }
}


public struct PostListEntity: Equatable {
    public var items: [PostListElement]
    public var lastCursorId: Int?
    public var hasNext: Bool
    
    public init(items: [PostListElement], lastCursorId: Int? = nil, hasNext: Bool) {
        self.items = items
        self.lastCursorId = lastCursorId
        self.hasNext = hasNext
    }
}

public struct PostItem: Identifiable, Equatable {
    public let id: Int
    public let type: PostType
    public let content: PostContent?
    public let isMyPost: Bool?
    
    public init(id: Int, type: PostType, content: PostContent? = nil, isMyPost: Bool = false) {
        self.id = id
        self.type = type
        self.content = content
        self.isMyPost = isMyPost
    }
}

public enum PostType: String, Equatable {
    case postItem = "PostItem"
}



public struct CommentEntity: Equatable {
    public let id: Int
    public let isMine: Bool
    public let profileImageURL: URL?
    public let nickname: String
    public let content: String
    public var likeCount: Int
    public var isLiked: Bool
    public let isReported: Bool
    public let createdAt: String
    
    
    public init(id: Int, isMine: Bool, profileImageURL: URL?, nickname: String, content: String, likeCount: Int, isLiked: Bool, isReported: Bool, createdAt: String) {
        self.id = id
        self.isMine = isMine
        self.profileImageURL = profileImageURL
        self.nickname = nickname
        self.content = content
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.isReported = isReported
        self.createdAt = createdAt
    }
}


public struct PostContent: Equatable {
    public let category: CategoryItemEntity?
    public let header: HeaderEntity
    public let info: InfoSectionEntity
    public let contentSection: ContentSectionEntity?
    public var footer: FooterSectionEntity
    public let button: ButtonEntity?
    
    public init(category: CategoryItemEntity?, header: HeaderEntity, info: InfoSectionEntity, contentSection: ContentSectionEntity?, footer: FooterSectionEntity, button: ButtonEntity?) {
        self.category = category
        self.header = header
        self.info = info
        self.contentSection = contentSection
        self.footer = footer
        self.button = button
    }
}

public struct CategoryItemEntity: Equatable {
    public let text: String
    public let textColor: String
    public let typography: String
    public let target: String
    public let iconURL: String
    public let iconColor: String
    
    public init(text: String, textColor: String, typography: String, target: String, iconURL: String, iconColor: String) {
        self.text = text
        self.textColor = textColor
        self.typography = typography
        self.target = target
        self.iconURL = iconURL
        self.iconColor = iconColor
    }
}

public struct HeaderEntity: Equatable {
    public let profileImageURL: String
    public let profileImageWidth: Int
    public let profileImageHeight: Int
    public let nickname: StyledText
    public let createdAt: StyledText
    public let category: CategoryItemEntity?
    public let button: ButtonEntity?
    
    public init(profileImageURL: String, profileImageWidth: Int, profileImageHeight: Int ,nickname: StyledText , createdAt: StyledText, category: CategoryItemEntity?, button: ButtonEntity? = nil) {
        self.profileImageURL = profileImageURL
        self.profileImageWidth = profileImageWidth
        self.profileImageHeight = profileImageHeight
        self.nickname = nickname
        self.createdAt = createdAt
        self.category = category
        self.button = button
    }
}

public struct InfoSectionEntity: Equatable {
    public let title: StyledText?
    public let description: StyledText
    public let seeMore: StyledText
    public let maxLine: Int
    
    public init(title: StyledText?, description: StyledText, seeMore: StyledText, maxLine: Int) {
        self.title = title
        self.description = description
        self.seeMore = seeMore
        self.maxLine = maxLine
    }
}

public enum ContentSectionEntity: Equatable {
    case images([ImageResource])
}

public struct ImageResource: Equatable {
    public let url: String
    public let size: CGSize?
    
    public init(url: String, size: CGSize?) {
        self.url = url
        self.size = size
    }
}

public struct FooterSectionEntity: Equatable {
    public var reactions: [Reaction]
    public var scrap: Scrap
    
    public init(reactions: [Reaction], scrap: Scrap) {
        self.reactions = reactions
        self.scrap = scrap
    }
}

public struct Reaction: Equatable {
    public let type: String
    public let iconURL: String
    public let iconColor: String
    public var count: StyledText
    public var selected: Bool
    
    public init(type: String, iconURL: String, iconColor: String, count: StyledText, selected: Bool) {
        self.type = type
        self.iconURL = iconURL
        self.iconColor = iconColor
        self.count = count
        self.selected = selected
    }
}

public struct Scrap: Equatable {
    public let iconURL: String
    public let iconColor: String
    public let selected: Bool
    
    public init(iconURL: String, iconColor: String, selected: Bool) {
        self.iconURL = iconURL
        self.iconColor = iconColor
        self.selected = selected
    }
}

public struct ButtonEntity: Equatable {
    public let type: String?
    public let title: StyledText?
    public let action: String?
    public let icon: IconEntity?
    public var isSelected: Bool?
    
    public init(type: String?, title: StyledText?, action: String?, icon: IconEntity?, isSelected: Bool?) {
        self.type = type
        self.title = title
        self.action = action
        self.icon = icon
        self.isSelected = isSelected
    }
}

public struct IconEntity: Equatable {
    public let url: String
    public let color: String
    
    public init(url: String, color: String) {
        self.url = url
        self.color = color
    }
}


public struct StyledText: Equatable {
    public let text: String
    public let color: String
    public let typography: String
    public let maxLine: Int
    
    public init(text: String, color: String, typography: String, maxLine: Int) {
        self.text = text
        self.color = color
        self.typography = typography
        self.maxLine = maxLine
    }
}

extension CGSize: @retroactive Equatable {
    public static func == (lhs: CGSize, rhs: CGSize) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
}
