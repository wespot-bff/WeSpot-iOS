//
//  CommunityRepository.swift
//  CommunityService
//
//  Created by 김도현 on 7/26/25.
//

import Foundation

import Networking
import CommunityDomain
import ComposableArchitecture

private enum CommunityRepositoryKey: DependencyKey {
  static let liveValue: CommunityRepositoryProtocol = CommunityRepository()
}

public extension DependencyValues {
  var communityRepository: CommunityRepositoryProtocol {
    get { self[CommunityRepositoryKey.self] }
    set { self[CommunityRepositoryKey.self] = newValue }
  }
}

private enum FetchPostImagePresignedURLUseCaseKey: DependencyKey {
    static let liveValue: FetchPostImagePresignedURLUseCaseProtocol = FetchPostImagePresignedURLUseCase(
        communityRepository: CommunityRepositoryKey.liveValue
      )
}

private enum UploadPostImageItemUseCaseKey: DependencyKey {
    static let liveValue: UploadPostImageItemUseCaseProtocol = UploadPostImageItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UploadPostItemUseCaseKey: DependencyKey {
    static let liveValue: UploadPostItemUseCaseProtocol = UploadPostItemUseCase(
        communityRepository: CommunityRepositoryKey.liveValue
      )
}


private enum FetchCategoryItemUseCaseKey: DependencyKey {
  static let liveValue: FetchCategoryItemUseCaseProtocol =
    FetchCategoryItemUseCase(
      communityRepository: CommunityRepositoryKey.liveValue
    )
}

private enum FetchCategoryDetailItemUseCaseKey: DependencyKey {
    static let liveValue: FetchCategoryDetailItemUseCaseProtocol =
    FetchCategoryDetailItemUseCase(
      communityRepository: CommunityRepositoryKey.liveValue
    )
}


public extension DependencyValues {
    var uploadPostImageItemUseCase: UploadPostImageItemUseCaseProtocol {
        get { self[UploadPostImageItemUseCaseKey.self]}
        set { self[UploadPostImageItemUseCaseKey.self] = newValue}
    }
    
    var fetchPostImagePresignedURLUseCase: FetchPostImagePresignedURLUseCaseProtocol {
        get { self[FetchPostImagePresignedURLUseCaseKey.self]}
        set { self[FetchPostImagePresignedURLUseCaseKey.self] = newValue}
    }
    
    var uploadPostItemUseCase: UploadPostItemUseCaseProtocol {
        get { self[UploadPostItemUseCaseKey.self]}
        set { self[UploadPostItemUseCaseKey.self] = newValue}
    }
    
  var fetchCategoryItemUseCase: FetchCategoryItemUseCaseProtocol {
    get { self[FetchCategoryItemUseCaseKey.self] }
    set { self[FetchCategoryItemUseCaseKey.self] = newValue }
  }
    
    var fetchCategoryDetailItemUseCase: FetchCategoryDetailItemUseCaseProtocol {
        get { self[FetchCategoryDetailItemUseCaseKey.self] }
        set { self[FetchCategoryDetailItemUseCaseKey.self] = newValue }
    }
}



public final class CommunityRepository: CommunityRepositoryProtocol {
    public func fetchPostDetailItems(query: CommunityDomain.FetchPostDetailItemRequestQuery) {
        
    }
    
        
    private let networkService: WSNetworkAsyncService = WSNetworkAsyncService()
    
    public init() {}
    
    
    public func fetchCategoryItems() async throws -> [FilterChipEntity] {
        let endPoint = CommunityEndPoint.fetchCategoryChips
        let responseDTO: [FilterChipResponseDTO] = try await networkService.request(endPoint: endPoint)
        return responseDTO.map { $0.toDomain() }
            
    }
    
    public func fetchCategoryDetailImtes() async throws -> [CategoryDetailEntity] {
        let endPoint = CommunityEndPoint.fetchCategoryDetailChips
        let responseDTO: [CategoryDetailResponseDTO] = try await networkService.request(endPoint: endPoint)
        
        return responseDTO.map { $0.toDomain() }
    }
    
    public func fetchPostImagePresignedURL(query: CommunityDomain.CreatePostImagePresignedURLQuery) async throws -> CommunityDomain.CreatePostImagePresignedURLEntity {
        let query = CreatePostImagePresignedURLRequestDTO(imageExtension: query.imageExtension)
        
        let endPoint = CommunityEndPoint.fetchPostImagePresignedURL(query)
        let responseDTO: CreatePostImagePresignedURLResponseDTO = try await networkService.request(endPoint: endPoint)
        
        return responseDTO.toDomain()
    }
    
    public func uploadPostImages(_ image: Data, presingedURL: String) async throws -> Bool {
        let endPoint = CommunityEndPoint.uploadPostImage(presingedURL)
        do {
            _ = try await networkService.upload(endPoint: endPoint, binaryData: image)
            return true
        } catch {
            print("🛑 uploadPostImage failed:", error)
            return false
        }
    }
    
    public func uploadPostItem(body: UploadPostItemRequest) async throws -> Bool {
        
        let imagesRequestDTO: [UploadPostImageRequestDTO] = body.imagesRequest.map { image in
            UploadPostImageRequestDTO(
                url: image.url
            )
        }
        let requestDTO = UploadPostRequestDTO(categoryId: body.categoryId, title: body.title, description: body.description, imagesRequest: imagesRequestDTO)
        
        let endPoint = CommunityEndPoint.uploadPost(requestDTO)
        print("서버 요청 보내는 값 확인 합니다 \(endPoint)")
        do {
            _ = try await networkService.request(endPoint: endPoint) as EmptyResponseDTO
            return true
        } catch {
            print("🛑 uploadPostItem failed:", error)
            return false
        }
    }
}
