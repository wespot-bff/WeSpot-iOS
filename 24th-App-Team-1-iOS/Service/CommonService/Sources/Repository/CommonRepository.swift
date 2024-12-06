//
//  CommonRepository.swift
//  CommonService
//
//  Created by eunseou on 8/4/24.
//

import Foundation
import Networking
import CommonDomain
import Util
import Extensions

import FirebaseRemoteConfig
import Firebase
import RxSwift
import RxCocoa

public final class CommonRepository: CommonRepositoryProtocol {
    
    
    private let networkService: WSNetworkServiceProtocol = WSNetworkService()
    private let dataSources: RemoteConfig = RemoteConfig.remoteConfig()
    
    public init() { }
    
    public func fetchUserProfileItems() -> Single<UserProfileEntity?> {
        let endPoint = CommonEndPoint.fetchUserProfile
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .decodeMap(UserProfileResponseDTO.self)
            .logErrorIfDetected(category: Network.error)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    
    
    public func updateUserProfileItem(body: UpdateUserProfileRequest) -> Single<Bool> {
        
        let body = UpdateUserProfileRequestDTO(introduction: body.introduction)
        let endPoint = CommonEndPoint.updateUserProfile(body)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .map { _ in true }
            .catchAndReturn(false)
            .logErrorIfDetected(category: Network.error)
            .asSingle()
    }
    
    public func createCheckProfanity(body: CreateCheckProfanityRequest) -> Single<Bool> {
        let query = CreateCheckProfanityRequestDTO(message: body.message)
        let endPoint = CommonEndPoint.createProfanityCheck(query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .map { data in
                return data.count > 0
            }
            .logErrorIfDetected(category: Network.error)
            .asSingle()
    }
    
    public func createReportUserItem(body: CreateUserReportRequest) -> Single<CreateReportUserEntity?> {
        let body = CreateUserReportRequestDTO(reportType: body.type, targetId: body.targetId)
        let endPoint = CommonEndPoint.createUserReport(body)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .decodeMap(CreateReportUserResponseDTO.self)
            .logErrorIfDetected(category: Network.error)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchVoteOptions() -> Single<VoteResponseEntity?> {
        let endPoint = CommonEndPoint.fetchVoteOptions
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(VoteResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func createProfilePresignedURL(query: CreateProfilePresignedURLQuery) -> Single<CreateProfilePresignedURLEntity?> {
        let query = CreateProfilePresignedURLRequestDTO(imageExtension: query.imageExtension)
        let endpoint = CommonEndPoint.fetchProfilePresignedURL(query)
        return networkService.request(endPoint: endpoint)
            .asObservable()
            .decodeMap(CreateProfilePresignedURLResponseDTO.self)
            .logErrorIfDetected(category: Network.error)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func uploadUserProfileImage(_ image: Data, presigendURL: String) -> Single<Bool> {
        let endpoint = CommonEndPoint.uploadProfileImage(presigendURL)
        return networkService.upload(endPoint: endpoint, binaryData: image)
            .asObservable()
            .map { _ in true }
            .catchAndReturn(false)
            .logErrorIfDetected(category: Network.error)
            .asSingle()
    }
    
    public func fetchAppVersionItem() async throws -> WSVersionEntity {
        let fetchStatus = try await dataSources.fetch(withExpirationDuration: 0)
        
        if fetchStatus == .success {
            try await dataSources.activate()
            guard let minVersion = dataSources.configValue(forKey: WSRemoteConfigKey.minversion.rawValue).stringValue,
                  let latestVersion = dataSources.configValue(forKey: WSRemoteConfigKey.latestVersion.rawValue).stringValue else {
                throw WSRemoteConfigError.notFoundVersion
            }
            return (latestVersion, minVersion)
        } else {
            throw WSRemoteConfigError.invalidFirebaseConfigure
        }
    }
}
