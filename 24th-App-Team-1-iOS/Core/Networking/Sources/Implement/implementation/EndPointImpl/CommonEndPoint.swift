//
//  CommonEndPoint.swift
//  Networking
//
//  Created by eunseou on 8/4/24.
//

import Foundation
import Storage

import Alamofire


public enum CommonEndPoint: WSNetworkEndPoint {
    private var accessToken: String {
        guard let accessToken = KeychainManager.shared.get(type: .accessToken) else {
            return ""
        }
        return accessToken
    }
    case allowPollcy(Encodable)
    
    case fetchUserProfile
    // 비속어 검색 API
    case createProfanityCheck(Encodable)
    /// 사용자 프로필 수정 API
    case updateUserProfile(Encodable)
    /// 질문지 조회 API
    case fetchVoteOptions
    /// 사용자 프로필 이미지 Presigned URL 요청 API
    case fetchProfilePresignedURL(Encodable)
    
    case uploadProfileImage(String)
    
    case fetchProfileOnboarding(Encodable)
    
    public var spec: WSNetworkSpec {
        switch self {
        case .allowPollcy:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/users/allow/policy")
        case .fetchUserProfile:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/me")
        case .createProfanityCheck:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/check-profanity")
        case .updateUserProfile:
            return WSNetworkSpec(method: .put, url: "\(WSNetworkConfigure.baseURL)/users/me")
        case .fetchVoteOptions:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/votes/options")
        case .fetchProfilePresignedURL:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/image/presigned-url")
        case let .uploadProfileImage(presignedURL):
            return WSNetworkSpec(method: .put, url: presignedURL)
        case let .fetchProfileOnboarding(pushType):
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/update-modal")
        }
    }
    
    
    public var parameters: WSRequestParameters {
        switch self {
        case let .allowPollcy(allowQuery):
            return .requestQuery(allowQuery)
        case .createProfanityCheck(let messsage):
            return .requestBody(messsage)
        case let .updateUserProfile(body):
            return .requestBody(body)
        case let .fetchProfilePresignedURL(query),
             let .fetchProfileOnboarding(query):
            return .requestQuery(query)
        default:
            return .none
        }
    }
    
    public var headers: HTTPHeaders {
        switch self {
        case .uploadProfileImage:
            return [
                "Content-Type": "image/jpeg",
            ]
        default:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        }
    }
}
