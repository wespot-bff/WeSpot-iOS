//
//  WSNetworkInterceptor.swift
//  Networking
//
//  Created by eunseou on 8/17/24.
//

import Foundation
import Storage
import Util

import Alamofire
import RxSwift
import RxCocoa

public final class WSNetworkInterceptor: RequestInterceptor {
    
    private var retryLimit = 2
    private let disposeBag = DisposeBag()
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        guard let accessToken = KeychainManager.shared.get(type: .accessToken) else {
            completion(.success(urlRequest))
            return
        }
        
        if let url = urlRequest.url?.absoluteString, url.contains("s3") {
            urlRequest.headers.add(name: "Content-Type", value: "image/jpeg")
            completion(.success(urlRequest))
            return
        }
        
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        completion(.success(urlRequest))
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        
        guard response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        guard let refreshToken = KeychainManager.shared.get(type: .refreshToken) else {
            return completion(.doNotRetryWithError(WSNetworkError.default(message: "리프레쉬 토큰을 찾을 수 없습니다.")))
        }
        
        let body = ReissueToken(token: refreshToken)
        let endPoint = ReissueEndPoint.createReissueToken(body: body)
        WSNetworkService().request(endPoint: endPoint)
            .asObservable()
            .decodeMap(AccessToken.self)
            .logErrorIfDetected(category: Network.error)
            .subscribe { token in
                KeychainManager.shared.set(value: token.accessToken, type: .accessToken)
                KeychainManager.shared.set(value: token.refreshToken, type: .refreshToken)
            } onError: { error in
                completion(.doNotRetryWithError(error))
            }
            .disposed(by: disposeBag)
        
    }
}
