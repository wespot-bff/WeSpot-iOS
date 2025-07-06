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
    public func requestWithStatusCode(endPoint: URLRequestConvertible) -> Single<(data: Data?, statusCode: Int)> {
        return Single<(data: Data?, statusCode: Int)>.create { single in
            WSNetworkService.session.request(endPoint)
                // MARK: 여기에 emptyResponseCodes를 추가합니다!
                .responseData(emptyResponseCodes: [201, 204]) { response in // <-- 이 부분 수정
                    let statusCode = response.response?.statusCode ?? 0
                    
                    switch response.result {
                    case let .success(data):
                        // 201/204 코드는 data가 nil로 올 수 있지만,
                        // Alamofire가 이젠 에러로 처리하지 않고 .success를 반환합니다.
                        // 따라서 데이터가 nil일 경우를 대비하여 Data()로 초기화하거나 옵셔널 Data를 반환하도록 합니다.
                        single(.success((data: data, statusCode: statusCode))) // data가 nil일 수 있으므로 Data() 또는 옵셔널 처리
                    case let .failure(error):
                        // Alamofire 자체의 에러(e.g., 네트워크 연결 끊김)
                        // 또는 4xx/5xx 상태 코드 에러
                        single(.failure(self.mapError(error: error, statusCode: statusCode))) // self.mapError 호출
                    }
                }
            return Disposables.create()
        }
    }

    public func requestAsync(endPoint: URLRequestConvertible) async throws -> Data {
        let dataResponse = await WSNetworkService.session
            .request(endPoint)
            .serializingData()
            .response
        switch dataResponse.result {
        case .success(let data):
            return data
        case .failure(let error):
            let statusCode = dataResponse.response?.statusCode
            throw mapError(error: error, statusCode: statusCode)
        }
    }
    
    private func mapError(error: AFError, statusCode: Int?) -> WSNetworkError {
        switch statusCode {
        case 400:
            return .badRequest(message: error.errorDescription ?? "")
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        default:
            return .default(message: error.errorDescription ?? error.localizedDescription)
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
