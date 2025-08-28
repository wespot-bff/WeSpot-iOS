//
//  CommunityEndPoint.swift
//  Networking
//
//  Created by 김도현 on 7/26/25.
//

import Foundation

import Alamofire
import Storage

public enum CommunityEndPoint: WSNetworkEndPoint {
    private var accessToken: String {
        guard let accessToken: String = KeychainManager.shared.get(type: .accessToken) else {
            return ""
        }
        return accessToken
    }
    
    case fetchSearchPost(Encodable)
    case updatePostLike(String)
    case updatePostScrap(String)
    case fetchPostAll(Encodable)
    case fetchPostDetails(Encodable)
    case uploadPost(Encodable)
    case uploadPostImage(String)
    case fetchCategoryChips
    case fetchCategoryDetailChips
    case fetchMyWrittenPost
    case fetchMyScrapPost
    case fetchMyCommnetPost
    case fetchPostImagePresignedURL(Encodable)
    case fetchPostDetail(String)
    case updateCommentNotification(String)
    case createComment(Encodable)
    case fetchComment(Encodable)
    case createCommentReport(String)
    case createCommentLike(String)
    case updatePostBlock(String)
    case updatePostReport(String)
    
    public var spec: WSNetworkSpec {
        switch self {
        case .fetchMyWrittenPost:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post/written")
        case .fetchMyScrapPost:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post/scrapped")
        case .fetchMyCommnetPost:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post/commented")
        case .fetchSearchPost:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post/search")
        case let .updatePostLike(postId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/\(postId)/like")
        case let .updatePostScrap(postId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/\(postId)/scrap")
        case .fetchPostAll:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post")
        case .fetchCategoryChips:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/category")
        case .fetchCategoryDetailChips:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/category/details")
        case .uploadPost:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post")
        case .fetchPostImagePresignedURL:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/image/presigned-url")
        case let .uploadPostImage(presignedURL):
            return WSNetworkSpec(method: .put, url: presignedURL)
        case .fetchPostDetails(_):
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post/details")
        case let .fetchPostDetail(postId):
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post/\(postId)")
        case let .updateCommentNotification(postId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/\(postId)/notification/comment")
        case let .createCommentReport(commentId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/comment/\(commentId)/report")
        case let .createCommentLike(commentId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/comment/\(commentId)/like")
        case let .updatePostBlock(postId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/\(postId)/block")
        case let .updatePostReport(postId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/\(postId)/report")
        case .createComment:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/post/comment")
        case .fetchComment:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/post/comment")
        }
    }
    
    public var parameters: WSRequestParameters {
        switch self {
        case let .fetchSearchPost(query):
            return .requestQuery(query)
        case let .fetchPostAll(query):
            return .requestQuery(query)
        case .fetchCategoryChips:
            return .none
        case .fetchCategoryDetailChips:
            return .none
        case let .createComment(body):
            return .requestBody(body)
        case let .uploadPost(body):
            return .requestBody(body)
        case let .fetchPostImagePresignedURL(query):
            return .requestQuery(query)
        case let .fetchPostDetails(query):
            return .requestQuery(query)
        case let .fetchComment(query):
            return .requestQuery(query)
        default:
            return .none
        }
    }
    
    public var headers: HTTPHeaders {
        switch self {
        case .uploadPostImage:
            return [
                "Content-Type": "image/jpeg",
            ]
        default:
            return  [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        }
    }
    
}
