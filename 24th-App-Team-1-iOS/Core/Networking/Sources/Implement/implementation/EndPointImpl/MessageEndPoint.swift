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
    // 받은 쪽지
    case getMessage(Encodable)
    // 쪽지 삭제
    case deleteMessage(Int)
    // 쪽지 차단
    case blockMessage(Int)
    // 쪽지 신고
    case reportMessage(Encodable)
    // 쪽지 읽기
    case readMessage(Int)
    
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
        case .getMessage:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages")
        case .deleteMessage(let messageID):
            return WSNetworkSpec(method: .delete, url: "\(WSNetworkConfigure.baseURL)/messages/\(messageID)")
        case .blockMessage(let messageID):
                return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/messages/\(messageID)/block")
        case .reportMessage:
            return WSNetworkSpec(method: .post,
                                 url: "\(WSNetworkConfigure.baseURL)/reports")
        case .readMessage(let messageID):
            return WSNetworkSpec(method: .put,
                                 url: "\(WSNetworkConfigure.baseURL)/messages/\(messageID)/read")

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
        case .getMessage(let query):
            return .requestQuery(query)
        case .deleteMessage:
            return .none
        case .blockMessage:
            return .none
        case .reportMessage(let body):
            return .requestBody(body)
        case .readMessage(_):
            return .none
        }
    }
    
    public var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer testToken"
        ]
    }
    
}
