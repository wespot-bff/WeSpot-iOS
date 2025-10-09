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

enum PostDetailError: Error {
    case unexpectedPostType
}

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

private enum FetchPostDetailItemUseCaseKey: DependencyKey {
    static let liveValue: FetchPostDetailItemUseCaseProtocol = FetchPostDetailItemUseCase(
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

private enum FetchReportReasonItemUseCaseKey: DependencyKey {
    static var liveValue: FetchReportReasonItemUseCaseProtocol {
        FetchReportReasonItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
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

private enum UpdateCommentNotificationUseCaseKey: DependencyKey {
    static let liveValue: UpdateCommentNotificationUseCaseProtocol = UpdateCommentNotificationUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum CreatePostCommentUseCaseKey: DependencyKey {
    static let liveValue: CreatePostCommentUseCaseProtocol = CreatePostCommentUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum FetchCommentItemUseCaseKey: DependencyKey {
    static let liveValue: FetchCommentItemUseCaseProtocol = FetchCommentItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UpdatePostReportUseCaseKey: DependencyKey {
    static let liveValue: UpdatePostReportUseCaseProtocol = UpdatePostReportUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UpdatePostBlockUseCaseKey: DependencyKey {
    static let liveValue: UpdatePostBlockUseCaseProtocol = UpdatePostBlockUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UpdateCommentLikeUseCaseKey: DependencyKey {
    static let liveValue: UpdateCommentLikeUseCaseProtocol = UpdateCommentLikeUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum UpdateCommentReportUseCaseKey: DependencyKey {
    static let liveValue: UpdateCommentReportUseCaseProtocol = UpdateCommentReportUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum DeletePostItemUseCaseKey: DependencyKey {
    static let liveValue: DeletePostItemUseCaseProtocol = DeletePostItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum DeleteCommentUseCaseKey: DependencyKey {
    static let liveValue: DeleteCommentUseCaseProtocol = DeleteCommentUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}

private enum EditPostItemUseCaseKey: DependencyKey {
    static let liveValue: EditPostItemUseCaseProtocol = EditPostItemUseCase(communityRepository: CommunityRepositoryKey.liveValue)
}


public extension DependencyValues {
    
    var fetchReportReasonItemUseCase: FetchReportReasonItemUseCaseProtocol {
        get { self[FetchReportReasonItemUseCaseKey.self] }
        set { self[FetchReportReasonItemUseCaseKey.self] = newValue }
    }
    
    var deletePostItemUseCase: DeletePostItemUseCaseProtocol {
        get { self[DeletePostItemUseCaseKey.self]}
        set { self[DeletePostItemUseCaseKey.self] = newValue}
    }
    
    var deleteCommentUseCase: DeleteCommentUseCaseProtocol {
        get { self[DeleteCommentUseCaseKey.self]}
        set { self[DeleteCommentUseCaseKey.self] = newValue}
    }
    
    var editPostItemUseCase: EditPostItemUseCaseProtocol {
        get { self[EditPostItemUseCaseKey.self]}
        set { self[EditPostItemUseCaseKey.self] = newValue}
    }
    
    var updateCommentReportUseCase: UpdateCommentReportUseCaseProtocol {
        get { self[UpdateCommentReportUseCaseKey.self]}
        set { self[UpdateCommentReportUseCaseKey.self] = newValue}
    }
    
    var updateCommentLikeUseCase: UpdateCommentLikeUseCaseProtocol {
        get { self[UpdateCommentLikeUseCaseKey.self]}
        set { self[UpdateCommentLikeUseCaseKey.self] = newValue}
    }
    
    var updatePostBlockUseCase: UpdatePostBlockUseCaseProtocol {
        get { self[UpdatePostBlockUseCaseKey.self]}
        set { self[UpdatePostBlockUseCaseKey.self] = newValue}
    }
    
    var updatePostReportUseCase: UpdatePostReportUseCaseProtocol {
        get { self[UpdatePostReportUseCaseKey.self]}
        set { self[UpdatePostReportUseCaseKey.self] = newValue}
    }
    
    var fetchCommentItemUseCase: FetchCommentItemUseCaseProtocol {
        get { self[FetchCommentItemUseCaseKey.self]}
        set { self[FetchCommentItemUseCaseKey.self] = newValue}
    }
    
    var createPostCommentUseCase: CreatePostCommentUseCaseProtocol {
        get { self[CreatePostCommentUseCaseKey.self]}
        set { self[CreatePostCommentUseCaseKey.self] = newValue}
    }
    
    var updateCommentNotificationUseCase: UpdateCommentNotificationUseCaseProtocol {
        get { self[UpdateCommentNotificationUseCaseKey.self]}
        set { self[UpdateCommentNotificationUseCaseKey.self] = newValue}
    }
    
    
    var fetchPostDetailItemUseCase: FetchPostDetailItemUseCaseProtocol {
        get { self[FetchPostDetailItemUseCaseKey.self]}
        set { self[FetchPostDetailItemUseCaseKey.self] = newValue}
    }
    
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
    
    public func updateCommentNotification(_ postId: String) async throws -> Bool {
        let endPoint = CommunityEndPoint.updateCommentNotification(postId)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        return response
    }
    
    public func fetchMyPostCommentItem() async throws -> PostListEntity {
        let endPoint = CommunityEndPoint.fetchMyCommnetPost
        let response: PostListResponseDTO = try await networkService.request(endPoint: endPoint)
        return response.toDomain()
    }
    
    public func fetchFeedDetailItem(postId: String) async throws -> PostItem {
        let endPoint = CommunityEndPoint.fetchPostDetail(postId)
        let response: PostItemDTO = try await networkService.request(endPoint: endPoint)
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
    
    
    public func updateCommentReport(_ commentId: String, body: ReportReasonRequest) async throws -> Bool {
        var requestItemDTO: [CreateReportReasonRequesItemtDTO] = []
        body.reportReasonRequests.forEach { body in
            requestItemDTO.append(CreateReportReasonRequesItemtDTO(reportReasonId: body.reportReasonId, customReason: body.customReason))
        }
        print("네 값을. 확인합니다 : \(requestItemDTO)")
        let endPoint = CommunityEndPoint.createCommentReport(commentId: commentId, body: requestItemDTO)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        return response
    }
    
    public func deleteComment(_ commentId: Int) async throws -> Bool {
        let endPoint = CommunityEndPoint.deleteComment(commentId)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        return response
    }
    
    public func fetchReportItem() async throws -> [ReportReason] {
        let endPoint = CommunityEndPoint.fetchReportItem
        let response: [FetchReportResponseDTO] = try await networkService.request(endPoint: endPoint)
        return response.map { $0.toDomain() }
    }
    
    public func editPostItem(_ postId: Int, body: UploadPostItemRequest) async throws -> Bool {
        
        let body = UploadPostRequestDTO(categoryId: body.categoryId, title: body.title, description: body.description, imagesRequest: body.imagesRequest)
        print("수정된 게시글 리스트 입니다 : \(body)")
        let endPoint = CommunityEndPoint.editPostItem(postId: postId, body: body)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        print("게시글 수정 했음? : \(response)")
        return response
    }
    
    public func deletePostItem(_ postId: Int) async throws -> Bool {
        let endPoint = CommunityEndPoint.deletePostItem(postId)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        return response
    }
    
    public func updateCommentLike(_ commentId: String) async throws -> Bool {
        let endPoint = CommunityEndPoint.createCommentLike(commentId)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        return response
    }
    
    public func updatePostReport(_ postId: String, body: ReportReasonRequest) async throws -> Bool {
        var requestItemDTO: [CreateReportReasonRequesItemtDTO] = []
        body.reportReasonRequests.forEach { body in
            requestItemDTO.append(CreateReportReasonRequesItemtDTO(reportReasonId: body.reportReasonId, customReason: body.customReason))
        }
        let body = CreateReportReasonRequestDTO(reportReasonRequests: requestItemDTO)
        
        let endPoint = CommunityEndPoint.updatePostReport(postId: postId, body: body)
        print("이건 뭐지 : \(endPoint)")
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        return response
    }
    
    public func updatePostBlock(_ postId: String) async throws -> Bool {
        let endPoint = CommunityEndPoint.updatePostBlock(postId)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        return response
    }
    
    public func fetchCommentItem(_ query: FetchCommentRequestQuery) async throws -> [CommentEntity] {
        let query = FetchCommentRequestDTO(postId: query.postId)
        let endPoint = CommunityEndPoint.fetchComment(query)
        let response: [CommentDTO] = try await networkService.request(endPoint: endPoint)
        return response.map { $0.toDomain() }
    }
    
    public func createPostComment(_ body: CommunityDomain.CreatePostCommentRequest) async throws -> Bool {
        let body = CreatePostCommentRequestDTO(postId: body.postId, content: body.content)
        let endPoint = CommunityEndPoint.createComment(body)
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
        
        return response
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
        return response
    }
    
    public func updatePostScrap(_ postId: Int) async throws -> Bool {
        let endPoint = CommunityEndPoint.updatePostScrap("\(postId)")
        let response = try await networkService.requestEmptyResponse(endPoint: endPoint)
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
            print("수정하는 이미지 들입니다 : \(presingedURL)")
            return true
        } catch {
            print("🛑 uploadPostImage failed:", error)
            return false
        }
    }
    
    public func uploadPostItem(body: UploadPostItemRequest) async throws -> Bool {
        
        let requestDTO = UploadPostRequestDTO(categoryId: body.categoryId, title: body.title, description: body.description, imagesRequest: body.imagesRequest)
        
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
