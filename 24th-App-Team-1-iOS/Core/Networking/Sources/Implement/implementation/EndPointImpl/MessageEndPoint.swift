//
//  MessageEndPoint.swift
//  Networking
//
//  Created by eunseou on 8/8/24.
//

import Foundation

import Alamofire

public enum MessageEndPoint: WSNetworkEndPoint {
    
    // 쪽지 상태 조회 API
    case messagesStatus
    // 예약된 쪽지 조회 API
    case fetchReservedMessages
    // 쪽지 조회 API
    case fetchMessages(Encodable)
    
    case searchStudent(Encodable)
    
    public var spec: WSNetworkSpec {
        switch self {
        case .messagesStatus:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages/status/me")
        case .fetchReservedMessages:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages/scheduled")
        case .fetchMessages:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages")
        case .searchStudent(_):
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/search")
        }
    }
    
    public var parameters: WSRequestParameters {
        switch self {
        case .messagesStatus:
            return .none
        case .fetchReservedMessages:
            return .none
        case .fetchMessages(let body):
            return .requestQuery(body)
        case .searchStudent(let body):
            return .requestQuery(body)

        }
    }
    
    public var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer testToken"
        ]
    }
    
}
