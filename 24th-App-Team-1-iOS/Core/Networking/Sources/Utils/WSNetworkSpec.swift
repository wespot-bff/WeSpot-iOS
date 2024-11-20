//
//  WSNetworkSpec.swift
//  Networking
//
//  Created by 김도현 on 11/18/24.
//

import Foundation

import Alamofire


/// 서버 요청을 보내기 위한 **URL**, **HTTP Method** 를 정의하기 위한 구조체 입니다.
public struct WSNetworkSpec {
    let method: HTTPMethod
    let url: String
    
    public init(method: HTTPMethod, url: String) {
        self.method = method
        self.url = url
    }
}
