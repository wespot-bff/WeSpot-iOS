//
//  WSNetworkServiceProtocol.swift
//  Networking
//
//  Created by Kim dohyun on 7/10/24.
//

import Foundation

import Alamofire
import RxSwift


public protocol WSNetworkServiceProtocol {
    func request(endPoint: URLRequestConvertible) -> Single<Data>
    func upload(endPoint: URLRequestConvertible, binaryData: Data) -> Single<Bool>
    func requestWithStatusCode(endPoint: URLRequestConvertible) -> Single<(data: Data?, statusCode: Int)>
    func requestAsync(endPoint: URLRequestConvertible) async throws -> Data
}
