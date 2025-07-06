//
//  VoteEndPoint.swift
//  Networking
//
//  Created by Kim dohyun on 7/22/24.
//

import Foundation
import Storage

import Alamofire


public enum VoteEndPoint: WSNetworkEndPoint {
    private var accessToken: String {
        guard let accessToken = KeychainManager.shared.get(type: .accessToken) else {
            return ""
        }
        return accessToken
    }
    
    /// 반 친구 조회 API
    case fetchClassMates
    /// 투표 하기 API
    case addVotes(Encodable)
    /// 투표 결과 전체 조회하기
    case fetchResultVotes(Encodable)
    /// 투표 결과 전체 조회하기 (1등)
    case fetchWinnerVotes(Encodable)
    /// 내가 받은 투표 목록 조회
    case fetchReceivedVotes(Encodable)
    /// 내가 받은 투표 개별 조회
    case fetchIndividualVotes(Int, Encodable)
    /// 내가 받은 투표 목록 조회
    case fetchVoteSent(Encodable)
    /// 유저 신고 API
    case createUserReport(Encodable)
    
    
    public var spec: WSNetworkSpec {
        switch self {
        case .fetchClassMates:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/classmates")
        case .addVotes:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/votes")
        case .fetchResultVotes:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/votes")
        case .fetchWinnerVotes:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/votes/tops")
        case .fetchReceivedVotes:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/votes/received")
        case let .fetchIndividualVotes(id, _):
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/votes/received/options/\(id)")
        case .fetchVoteSent:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/votes/sent")
        case .createUserReport:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/reports")
        }
    }
    
    public var parameters: WSRequestParameters {
        switch self {
        case let .fetchWinnerVotes(winnerQuery):
            return .requestQuery(winnerQuery)
        case let .addVotes(body):
            return .requestBody(body)
        case let .fetchResultVotes(allQuery):
            return .requestQuery(allQuery)
        case let .fetchReceivedVotes(receivedQuery):
            return .requestQuery(receivedQuery)
        case let .fetchVoteSent(sentQuery):
            return .requestQuery(sentQuery)
        case let .fetchIndividualVotes(_, individualQuery):
            return .requestQuery(individualQuery)
        case let .createUserReport(body):
            return .requestBody(body)
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
