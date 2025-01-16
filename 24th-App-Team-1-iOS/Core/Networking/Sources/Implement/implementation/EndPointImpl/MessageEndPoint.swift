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
    // 학생 조회
    case searchStudent(Encodable)
    // 비속어 체크
    case checkProfanity(Encodable)
    // 쪽지 보내기
    case sendMessage(Encodable)
    
    public var spec: WSNetworkSpec {
        switch self {
        case .messagesStatus:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages/status/me")
        case .fetchReservedMessages:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages/scheduled")
        case .fetchMessages:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages")
        case .searchStudent:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/search")
        case .checkProfanity:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/check-profanity")
        case .sendMessage:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/messages/send")
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
        case .checkProfanity(let body):
            return .requestBody(body)
        case .sendMessage(let body):
            return .requestBody(body)
        }
    }
    
    public var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer testToken"
        ]
    }
    
}
