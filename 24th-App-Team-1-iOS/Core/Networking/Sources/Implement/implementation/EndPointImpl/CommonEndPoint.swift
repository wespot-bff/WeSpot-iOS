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
    
    case fetchUserProfile
    // 비속어 검색 API
    case createProfanityCheck(Encodable)
    // 유저 신고 API
    case createUserReport(Encodable)
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
        case .fetchUserProfile:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/me")
        case .createProfanityCheck:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/check-profanity")
        case .createUserReport:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/reports")
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
    
    public var path: String {
        switch self {
        case .fetchUserProfile:
            return "/users/me"
        case .createProfanityCheck:
            return "/check-profanity"
        case .createUserReport:
            return "/reports"
        case .updateUserProfile:
            return "/users/me"
        case .fetchVoteOptions:
            return "/votes/options"
        case .fetchProfilePresignedURL:
            return "/image/presigned-url"
        case .uploadProfileImage:
            return ""
        case .fetchProfileOnboarding:
            return "/update-modal"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .fetchUserProfile:
            return .get
        case .createProfanityCheck:
            return .post
        case .createUserReport:
            return .post
        case .updateUserProfile:
            return .put
        case .fetchVoteOptions:
            return .get
        case .fetchProfilePresignedURL:
            return .get
        case .uploadProfileImage:
            return .put
        case .fetchProfileOnboarding:
            return .get
        }
    }
    
    public var parameters: WSRequestParameters {
        switch self {
        case .createProfanityCheck(let messsage):
            return .requestBody(messsage)
        case let .createUserReport(body):
            return .requestBody(body)
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
