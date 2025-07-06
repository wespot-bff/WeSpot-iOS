//
//  WSNetworkAsyncService.swift
//  Networking
//
//  Created by 김도현 on 2/25/25.
//

import Foundation

import Alamofire

public final class WSNetworkAsyncService: WSNetworkAsyncServiceProtocol {
    
    private static let session: Session = {
        let networkMonitor: WSNetworkMonitor = WSNetworkMonitor()
        let networkConfigure: URLSessionConfiguration = URLSessionConfiguration.af.default
        let interceptor = WSNetworkInterceptor()
        networkConfigure.timeoutIntervalForRequest = 60
        let networkSession: Session = Session(
            configuration: networkConfigure,
            interceptor: interceptor,
            eventMonitors: [networkMonitor]
        )
        return networkSession
    }()
    
    public init() { }
    
    public func request<T: Decodable>(endPoint: any URLRequestConvertible) async throws -> T {
        
        return try await withCheckedThrowingContinuation { continuation in
            WSNetworkAsyncService.session.request(endPoint)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case let .success(response):
                        continuation.resume(returning: response)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

}
