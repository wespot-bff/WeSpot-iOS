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

private enum UpdatePostLikeUseCaseKey: DependencyKey {
    static let liveValue: UpdatePostLikeUseCaseProtocol = UpdatePostLikeUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UpdatePostScrapUseCaseKey: DependencyKey {
    static let liveValue: UpdatePostScrapUseCaseProtocol = UpdatePostScrapUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UploadPostImageItemUseCaseKey: DependencyKey {
    static let liveValue: UploadPostImageItemUseCaseProtocol = UploadPostImageItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UploadPostItemUseCaseKey: DependencyKey {
    static let liveValue: UploadPostItemUseCaseProtocol = UploadPostItemUseCase(
        communityRepository: CommunityRepositoryKey.liveValue
      )
}

private enum FetchPostAllItemListUseCaseKey: DependencyKey {
    static let liveValue: FetchPostAllItemUseCaseProtocol = FetchPostAllItemUseCase(
        communityRepository: CommunityRepositoryKey.liveValue
    )
}

private enum FetchPostItemListUseCaseKey: DependencyKey {
    static let liveValue: FetchPostItemListUseCaseProtocol = FetchPostItemListUseCase(
        communityRepository: CommunityRepositoryKey.liveValue
    )
}

private enum FetchSearchPostItemUseCaseKey: DependencyKey {
    static let liveValue: FetchSearchPostItemUseCaseProtocol =
    FetchSearchPostItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum FetchMyScrapItemUseCaseKey: DependencyKey {
    static var liveValue: FetchMyScrapItemUseCaseProtocol {
        FetchMyScrapItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
    }
}

private enum FetchMyPostCommnetItemUseCaseKey: DependencyKey {
    static var liveValue: FetchMyPostCommnetItemUseCaseProtocol {
        return FetchMyPostCommnetItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
    }
}

private enum FetchMyPostWrittenItemUseCaseKey: DependencyKey {
    static var liveValue: FetchMyPostWrittenItemUseCaseProtocol {
        FetchMyPostWrittenItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
    }
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
    var fetchMyPostWrittenItemUseCase: FetchMyPostWrittenItemUseCaseProtocol {
        get { self[FetchMyPostWrittenItemUseCaseKey.self] }
        set { self[FetchMyPostWrittenItemUseCaseKey.self] = newValue }
    }
    
    var fetchMyPostCommnetItemUseCase: FetchMyPostCommnetItemUseCaseProtocol {
        get { self[FetchMyPostCommnetItemUseCaseKey.self]}
        set { self[FetchMyPostCommnetItemUseCaseKey.self] = newValue}
    }
    
    var fetchMyScrapItemUseCase: FetchMyScrapItemUseCaseProtocol {
        get { self[FetchMyScrapItemUseCaseKey.self]}
        set { self[FetchMyScrapItemUseCaseKey.self] = newValue}
    }
    
    var fetchSearchPostItemUseCase: FetchSearchPostItemUseCaseProtocol {
        get { self[FetchSearchPostItemUseCaseKey.self]}
        set { self[FetchSearchPostItemUseCaseKey.self] = newValue}
    }
    
    var updatePostLikeUseCase: UpdatePostLikeUseCaseProtocol {
        get { self[UpdatePostLikeUseCaseKey.self]}
        set { self[UpdatePostLikeUseCaseKey.self] = newValue }
    }
    
    var updatePostScrapUseCase: UpdatePostScrapUseCaseProtocol {
        get { self[UpdatePostScrapUseCaseKey.self]}
        set { self[UpdatePostScrapUseCaseKey.self] = newValue}
    }
    
    var fetchPostAllItemListUseCase: FetchPostAllItemUseCaseProtocol {
        get { self[FetchPostAllItemListUseCaseKey.self] }
        set { self[FetchPostAllItemListUseCaseKey.self] = newValue}
    }
    
    var fetchPostItemListUseCase: FetchPostItemListUseCaseProtocol {
        get { self[FetchPostItemListUseCaseKey.self] }
        set { self[FetchPostItemListUseCaseKey.self] = newValue}
    }
    
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
    
        
    private let networkService: WSNetworkAsyncService = WSNetworkAsyncService()
    
    public init() {}
    
    public func fetchMyPostCommentItem() async throws -> PostListEntity {
        let endPoint = CommunityEndPoint.fetchMyCommnetPost
        let response: PostListResponseDTO = try await networkService.request(endPoint: endPoint)
        return response.toDomain()
    }
    
    public func fetchMyPostScrapItem() async throws -> PostListEntity {
        let endPoint = CommunityEndPoint.fetchMyScrapPost
        let response: PostListResponseDTO = try await networkService.request(endPoint: endPoint)
        return response.toDomain()
    }
    
    public func fetchMyPostWrittenItem() async throws -> PostListEntity {
        let endPoint = CommunityEndPoint.fetchMyWrittenPost
        let response: PostListResponseDTO = try await networkService.request(endPoint: endPoint)
        return response.toDomain()
    }
    
    
    public func fetchSearchPostItems(query: FetchPostSearchKeywordQuery) async throws -> PostListEntity {
        let query = FetchPostSearchKeywordRequestDTO(keyword: query.keyword)
        let endPoint = CommunityEndPoint.fetchSearchPost(query)
        let response: PostListResponseDTO = try await networkService.request(endPoint: endPoint)
        return response.toDomain()
    }
    
    public func updatePostLike(_ postId: Int) async throws -> Bool {
        let endPoint = CommunityEndPoint.updatePostLike("\(postId)")
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        print("성공 확인합니다2 : \(response)")
        return response
    }
    
    public func updatePostScrap(_ postId: Int) async throws -> Bool {
        let endPoint = CommunityEndPoint.updatePostScrap("\(postId)")
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        print("성공 확인합니다 : \(response)")
        return response
    }
    
    public func fetchPostAllItems(query: FetchPostAllItemRequestQuery) async throws -> PostListEntity {
        let query = FetchPostAllRequestDTO(majorCategoryName: query.majorCategoryName, countOfPostsViewed: query.countOfPostsViewed, inquirySize: query.inquirySize, cursorId: query.cursorId)
        let endPoint = CommunityEndPoint.fetchPostAll(query)
        let responseDTO: PostListResponseDTO = try await networkService.request(endPoint: endPoint)
        return responseDTO.toDomain()
    }
    
    public func fetchPostDetailItems(query: CommunityDomain.FetchPostDetailItemRequestQuery) async throws -> CommunityDomain.PostListEntity {
        let query = FetchPostDetailItemRequestDTO(categoryId: query.categoryId, inquirySize: query.inquirySize, cursorId: query.cursorId)
        let endPoint = CommunityEndPoint.fetchPostDetails(query)
        let responseDTO: PostListResponseDTO = try await networkService.request(endPoint: endPoint)
        return responseDTO.toDomain()
    }
    
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
            _ = try await networkService.requestEmptyResponse(endPoint: endPoint)
            return true
        } catch {
            print("🛑 uploadPostItem failed:", error)
            return false
        }
    }
}
