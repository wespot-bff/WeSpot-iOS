//
//  WSNetworkEndPoint.swift
//  Networking
//
//  Created by Kim dohyun on 7/10/24.
//

import Foundation

import Alamofire

public protocol WSNetworkEndPoint: URLRequestConvertible {
    var spec: WSNetworkSpec { get }
    var parameters: WSRequestParameters { get }
    var headers: HTTPHeaders { get }
}


public extension WSNetworkEndPoint {
    
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: spec.url) else {
            throw URLError(.badURL)
        }
        let method = spec.method
        var urlRequest = try URLRequest(url: url, method: method)
        
        switch parameters {
        case let .requestBody(body):
            urlRequest.httpBody = try setupRequestBody(body: body)
        case let .requestQuery(query):
            urlRequest.url = try setupRequestQuery(url, paramters: query)
        case let .reuqestQueryWithBody(query, body: body):
            urlRequest.url = try setupRequestQuery(url, paramters: query)
            urlRequest.httpBody = try setupRequestBody(body: body)
        case .none:
            break
        }
        urlRequest.headers = headers
        return urlRequest
    }
    
    
    private func setupRequestQuery(_ url: URL, paramters: Encodable?) throws -> URL {
        let params = paramters?.toDictionary() ?? [:]
        let queryParams = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        var components = URLComponents(string: url.absoluteString)
        
        components?.queryItems = queryParams
        guard let originURL = components?.url else {
            throw URLError(.badURL)
        }
        return originURL
    }
    
    private func setupRequestBody(body: Encodable?) throws -> Data {
        let params = body?.toDictionary() ?? [:]
        return try JSONSerialization.data(withJSONObject: params, options: [])
    }
}
