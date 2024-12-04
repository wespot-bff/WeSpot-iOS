//
//  LoginEndPoint.swift
//  Networking
//
//  Created by eunseou on 7/30/24.
//

import Foundation

import Alamofire

public enum LoginEndPoint: WSNetworkEndPoint {
    
    // 소셜로그인 API
    case executeSocialLogin(Encodable)
    // 회원가입 API
    case executeSingUp(Encodable)
    // 토큰 재발행 API
    case generateRefreshToken(Encodable)
    // 학교 정보 검색 API
    case fetchSchoolList(Encodable)
    
    public var spec: WSNetworkSpec {
        switch self {
        case .executeSingUp:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/auth/signup")
        case .executeSocialLogin:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/auth/login")
        case .fetchSchoolList:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/schools/search")
        case .generateRefreshToken:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/auth/reissue"))")
        }
    }
    
    
    public var parameters: WSRequestParameters {
        switch self {
        case .executeSocialLogin(let body):
            return .requestBody(body)
        case .executeSingUp(let body):
            return .requestBody(body)
        case .generateRefreshToken(let body):
            return .requestBody(body)
        case .fetchSchoolList(let name):
            return .requestQuery(name)
        }
    }
    
    
    public var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json"
        ]
    }
}
