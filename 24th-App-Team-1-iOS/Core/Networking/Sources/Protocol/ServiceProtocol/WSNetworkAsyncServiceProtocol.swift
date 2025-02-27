//
//  WSNetworkAsyncServiceProtocol.swift
//  Networking
//
//  Created by 김도현 on 2/25/25.
//

import Foundation

import Alamofire

public protocol WSNetworkAsyncServiceProtocol {
    func request<T: Decodable>(endPoint: URLRequestConvertible) async throws -> T
}
