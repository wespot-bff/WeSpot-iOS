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
    case createSocialLogin(Encodable)
    // 회원가입 API
    case createAccount(Encodable)
    // 토큰 재발행 API
    case createRefreshToken(Encodable)
    // 학교 정보 검색 API
    case fetchSchoolList(Encodable)
    
    public var spec: WSNetworkSpec {
        switch self {
        case .createAccount:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/auth/signup")
        case .createSocialLogin:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/auth/login")
        case .fetchSchoolList:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/schools/search")
        case .createRefreshToken:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/auth/reissue"))")
        }
    }
    
    
    public var parameters: WSRequestParameters {
        switch self {
        case .createSocialLogin(let body):
            return .requestBody(body)
        case .createAccount(let body):
            return .requestBody(body)
        case .createRefreshToken(let body):
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
