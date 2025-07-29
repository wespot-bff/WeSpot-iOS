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
    
    /// 게시글 상세 조회 API
    /// Parameter : postID(String)
//    case fetchPostDetail(Encodable)
    /// 카테고리 칩으로 게시글 조회 할때 API
    /// Parameter :
    /// - majorCategoryName(String)
    /// - inquirySize(String)
    /// - cursorId(String)
//    case fetchFiterChipSearch(Encodable)
    /// 내가 작성한 글 목록 조회 API
    /// Parameter
    /// - inquirySize(Int)
    ///
//    case fetchWritten(Encodable)
    
    case fetchPostDetails(Encodable)
    case uploadPost(Encodable)
    case uploadPostImage(String)
    case fetchCategoryChips
    case fetchCategoryDetailChips
    case fetchPostImagePresignedURL(Encodable)
    
    public var spec: WSNetworkSpec {
        switch self {
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
        }
    }
    
    public var parameters: WSRequestParameters {
        switch self {
        case .fetchCategoryChips:
            return .none
        case .fetchCategoryDetailChips:
            return .none
        case let .uploadPost(body):
            return .requestBody(body)
        case let .fetchPostImagePresignedURL(query):
            return .requestQuery(query)
        case let .fetchPostDetails(query):
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
