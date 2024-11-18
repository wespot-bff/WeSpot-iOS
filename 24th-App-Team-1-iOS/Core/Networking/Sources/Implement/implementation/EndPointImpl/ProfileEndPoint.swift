//
//  ProfileEndPoint.swift
//  Networking
//
//  Created by Kim dohyun on 8/12/24.
//

import Foundation
import Storage

import Alamofire


public enum ProfileEndPoint: WSNetworkEndPoint {
    private var accessToken: String {
        guard let accessToken = KeychainManager.shared.get(type: .accessToken) else {
            return ""
        }
        return accessToken
    }
    
    /// 사용자 프로필 조회 API
    case fetchUserProfile
    /// 알람 설정 API
    case updateNotification(Encodable)
    /// 알람 설정 조회 API
    case fetchNotification
    /// 사용자 차단 목록 API
    case fetchUserBlock(Encodable)
    /// 사용자 차단 해체 API
    case updateUserBlock(String)
    /// 사용자 회원 탈퇴 API
    case updateUserResign
    /// 사용자 프로필 이미지 수정 API
    case editProfileImage(Encodable)
    
    public var spec: WSNetworkSpec {
        switch self {
        case .fetchUserProfile:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/me")
        case .updateNotification:
            return WSNetworkSpec(method: .put, url: "\(WSNetworkConfigure.baseURL)/users/settings")
        case .fetchNotification:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/settings")
        case .fetchUserBlock:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages/blocked")
        case let .updateUserBlock(messageId):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/messages/\(messageId)/unblock")
        case .updateUserResign:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/users/revoke")
        case .editProfileImage:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/image/update-profile")
        }
    }
    
    public var parameters: WSRequestParameters {
        switch self {
        case let .updateNotification(body):
            return .requestBody(body)
        case let .fetchUserBlock(query):
            return .requestQuery(query)
        case let .editProfileImage(query):
            return .requestQuery(query)
        default:
            return .none
        }
    }
    
    public var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
    }
}
