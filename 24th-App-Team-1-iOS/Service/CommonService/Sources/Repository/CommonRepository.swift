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
import Storage

import FirebaseRemoteConfig
import Firebase
import RxSwift
import RxCocoa

public final class CommonRepository: CommonRepositoryProtocol {
    
    
    private let networkService: WSNetworkServiceProtocol = WSNetworkService()
    private let networkAsyncService: WSNetworkAsyncServiceProtocol = WSNetworkAsyncService()
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
    
    public func fetchVoteOptions() -> Single<VoteResponseEntity?> {
        let endPoint = CommonEndPoint.fetchVoteOptions
        if let cacheResponse: VoteResponseDTO = WSCacheManager.shared.getResponse(for: WSCacheKey.voteOptions.rawValue) {
            return .just(cacheResponse.toDomain())
        }
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(VoteResponseDTO.self)
            .do(onNext: { response in
                WSCacheManager.shared.save(response: response, for: WSCacheKey.voteOptions.rawValue)
            })
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
                  let latestVersion = dataSources.configValue(forKey: WSRemoteConfigKey.latestVersion.rawValue).stringValue,
                  let updateType = dataSources.configValue(forKey: WSRemoteConfigKey.updateType.rawValue).stringValue else {
                throw WSRemoteConfigError.notFoundVersion
            }
            return (latestVersion, minVersion, updateType)
        } else {
            throw WSRemoteConfigError.invalidFirebaseConfigure
        }
    }
    
    public func fetchProfileOnbardingItem(query: ProfileOnboardingQuery) async throws -> ProfileOnboardingEntity {
        let query = ProfileOnbardingInfoRequestDTO(publishNotificationType: query.publishNotificationType)
        let endPoint = CommonEndPoint.fetchProfileOnboarding(query)
        let responseDTO: ProfileOnboardingResponseDTO = try await networkAsyncService.request(endPoint: endPoint)
        return responseDTO.toDomain()
    }
}
