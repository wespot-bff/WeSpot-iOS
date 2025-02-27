//
//  WSNetworkService.swift
//  Networking
//
//  Created by Kim dohyun on 7/10/24.
//

import Foundation

import Alamofire
import RxSwift

public final class WSNetworkService: WSNetworkServiceProtocol {
    
    //MARK: Property
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
    
    //MARK: Functions
    public func request(endPoint: URLRequestConvertible) -> Single<Data> {
        return Single<Data>.create { single in
            WSNetworkService.session.request(endPoint)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case let .success(response):
                        single(.success(response))
                    case let .failure(error):
                        switch response.response?.statusCode {
                        case 400:
                            single(.failure(WSNetworkError.badRequest(message: response.request?.url?.absoluteString ?? "")))
                        case 401:
                            single(.failure(WSNetworkError.unauthorized))
                        case 404:
                            single(.failure(WSNetworkError.notFound))
                        default:
                            single(.failure(WSNetworkError.default(message: error.localizedDescription)))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    /// requestWithStatusCode
    public func requestWithStatusCode(endPoint: URLRequestConvertible) -> Single<(data: Data, statusCode: Int)> {
        return Single<(data: Data, statusCode: Int)>.create { single in
            WSNetworkService.session.request(endPoint)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    let statusCode = response.response?.statusCode ?? 0
                    switch response.result {
                    case let .success(data):
                        // 성공 시 Data와 StatusCode를 함께 반환
                        single(.success((data: data, statusCode: statusCode)))
                    case let .failure(error):
                        // 실패 시 StatusCode 기반 에러 처리
                        switch statusCode {
                        case 400:
                            single(.failure(WSNetworkError.badRequest(message: response.request?.url?.absoluteString ?? "")))
                        case 401:
                            single(.failure(WSNetworkError.unauthorized))
                        case 404:
                            single(.failure(WSNetworkError.notFound))
                        default:
                            single(.failure(WSNetworkError.default(message: error.localizedDescription)))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    
    public func upload(endPoint: URLRequestConvertible, binaryData: Data) -> Single<Bool> {
        return Single<Bool>.create { single in
       WSNetworkService.session.upload(binaryData, with: endPoint)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success(_):
                        single(.success(true))
                    case let .failure(error):
                        switch response.response?.statusCode {
                        case 400:
                            single(.failure(WSNetworkError.badRequest(message: response.request?.url?.absoluteString ?? "")))
                        case 401:
                            single(.failure(WSNetworkError.unauthorized))
                        case 404:
                            single(.failure(WSNetworkError.notFound))
                        default:
                            single(.failure(WSNetworkError.default(message: error.localizedDescription)))
                        }
                    }
                }
            return Disposables.create()
        }
    }
}
