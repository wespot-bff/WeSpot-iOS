//
//  FeedDetailFeature.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/18/25.
//

import ComposableArchitecture
import CommunityDomain
import Extensions
import Foundation

@Reducer
public struct FeedDetailFeature {
    @Dependency(\.fetchPostDetailItemUseCase) var fetchPostDetailItemUsecCase: FetchPostDetailItemUseCaseProtocol
    @Dependency(\.updatePostScrapUseCase) var updatePostDetailScrapUseCase: UpdatePostScrapUseCaseProtocol
    @Dependency(\.updatePostLikeUseCase) var updatePostDetailLikeUseCase: UpdatePostLikeUseCaseProtocol
    @Dependency(\.updateCommentNotificationUseCase) var updateCommentNotificationUseCase: UpdateCommentNotificationUseCaseProtocol
    @Dependency(\.fetchCommentItemUseCase) var fetchCommentItemUseCase: FetchCommentItemUseCaseProtocol
    @Dependency(\.createPostCommentUseCase) var createPostCommentUseCase: CreatePostCommentUseCaseProtocol
    @Dependency(\.updateCommentLikeUseCase) var updateCommentLikeUseCase: UpdateCommentLikeUseCaseProtocol
    
    public struct CommentLikeOverride: Equatable {
        var isLiked: Bool
        var likeCountDelta: Int
    }
    
    @ObservableState
    public struct State: Equatable {
        var postEntity: PostItem? = nil
        var rawPostListItems: PostItem? = nil
        var originalPostData: PostItem?
        var commentItem: [CommentEntity] = []
        var originalComments: [CommentEntity] = []
        var postId: String
        var overrides: [Int: PostLocalOverride] = [:]
        var commentLikeOverrides: [String: CommentLikeOverride] = [:]
        var isShowingChatTextField: Bool = false
        
        
        var originalLikeState: [Int: Bool] = [:]
        var originalScrapState: [Int: Bool] = [:]
        var originalNotificationState: [Int: Bool] = [:]
        
        var pendingComments: [CommentEntity] = []

        var commentsForUI: [CommentEntity] {
            let allComments = commentItem + pendingComments
            // 댓글 좋아요 오버라이드 적용
            return allComments.map { comment in
                if let override = commentLikeOverrides[String(comment.id)] {
                    var updatedComment = comment
                    updatedComment.isLiked = override.isLiked
                    updatedComment.likeCount = max(0, comment.likeCount + override.likeCountDelta)
                    return updatedComment
                }
                return comment
            }
        }
        
        var isCommentLike: Bool = false
        var isScrap: Bool = false
        var isLoke: Bool = false
        var isNotification: Bool = false
        var chatInputText: String = ""
        
        public init(postId: String) {
            self.postId = postId
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case inner(Inner)
        case binding(BindingAction<State>)
    }
    
    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case didTappedLike(Int)
        case didTappedScrap(Int)
        case didTappedCommentLike(String)
        case dismissChatTextField
        case didTappedChat
        case didTappedSendChat(String, String)
        case chatInputTextChanged(String)
        case didTappedCommentNotification(Int)
        case likeResponseSuccess(postId: Int)
        case commentLikeResponseSuccess(commentId: String)
        case commentLikeResponseFailure(commentId: String, errorMessage: String)
        case likeResponseFailure(postId: Int, errorMessage: String)
        case scrapResponseSuccess(postId: Int)
        case scrapResponseFailure(postId: Int, errorMessage: String)
        case commentNotificationSuccess(postId: Int)
        case commentNotificationFailure(postId: Int, errorMessage: String)
        
    }
    
    public enum Inner: Equatable {
        case postDetailResponse(TaskResult<PostItem>)
        case postCommentResponse(TaskResult<[CommentEntity]>)
        case createCommentFinished(TaskResult<Bool>)
        case clearCommentOverride(commentId: String)
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce { state, action in
            switch action {
            case .binding:
                
                return .none
            case .view(.binding):
                return .none
                
            case .view(.onAppear):
                let postId = state.postId
                let commentQuery = FetchCommentRequestQuery(postId: postId)
                return .run { send in
                    do {
                        let postDetail = try await fetchPostDetailItemUsecCase.execute(postId: postId)
                        let comment = try await fetchCommentItemUseCase.execute(commentQuery)
                        await send(.inner(.postDetailResponse(.success(postDetail))))
                        await send(.inner(.postCommentResponse(.success(comment))))
                    } catch {
                        await send(.inner(.postDetailResponse(.failure(error))))
                    }
                    
                }
                
            case .inner(.postDetailResponse(.success(let postDetail))):
                state.rawPostListItems = postDetail
                state.postEntity = postDetail
                
                if let content = postDetail.content {
                    if let likeReaction = content.footer.reactions.first(where: { $0.type == "Like" }) {
                        state.originalLikeState[postDetail.id] = likeReaction.selected
                    }
                    
                    state.originalScrapState[postDetail.id] = content.footer.scrap.selected
                    
                    state.originalNotificationState[postDetail.id] = content.header.button?.isSelected ?? false
                }
                
                return .none
                
            case .inner(.postDetailResponse(.failure)):
                return .none
            case let .view(.didTappedLike(postId)):
                let originalLiked = state.originalLikeState[postId] ?? false
                
                if var override = state.overrides[postId] {
                    let currentLiked = override.isLiked ?? originalLiked
                    let newLiked = !currentLiked
                    
                    override.isLiked = newLiked
                    
                    if originalLiked {
                        override.likeCountDelta = newLiked ? 0 : -1
                    } else {
                        override.likeCountDelta = newLiked ? 1 : 0
                    }
                    
                    state.overrides[postId] = override
                } else {
                    let newLiked = !originalLiked
                    state.overrides[postId] = PostLocalOverride(
                        isLiked: newLiked,
                        likeCountDelta: newLiked ? 1 : -1,
                        isScrapped: nil,
                        isNotified: nil
                    )
                }
                applyOverrides(to: &state)
                
                return .run { send in
                    do {
                        try await updatePostDetailLikeUseCase.execute(postId: postId)
                        await send(.view(.likeResponseSuccess(postId: postId)))
                    } catch {
                        await send(.view(.likeResponseFailure(postId: postId, errorMessage: error.localizedDescription)))
                    }
                }

                
            case let .view(.didTappedCommentLike(commentId)):
                let originalComment = state.originalComments.first(where: { String($0.id) == commentId })
                let originalLiked = originalComment?.isLiked ?? false
                let originalLikeCount = originalComment?.likeCount ?? 0
                
                if let existingOverride = state.commentLikeOverrides[commentId] {
                    let currentLiked = existingOverride.isLiked
                    let newLiked = !currentLiked
                    
                    var newLikeCountDelta: Int
                    if originalLiked {
                        newLikeCountDelta = newLiked ? 0 : -1
                    } else {
                        newLikeCountDelta = newLiked ? 1 : 0
                    }
                    
                    state.commentLikeOverrides[commentId] = CommentLikeOverride(
                        isLiked: newLiked,
                        likeCountDelta: newLikeCountDelta
                    )
                } else {
                    let newLiked = !originalLiked
                    state.commentLikeOverrides[commentId] = CommentLikeOverride(
                        isLiked: newLiked,
                        likeCountDelta: newLiked ? 1 : -1
                    )
                }
                
                return .run { send in
                    do {
                        try await updateCommentLikeUseCase.execute(commentId)
                        await send(.view(.commentLikeResponseSuccess(commentId: commentId)))
                    } catch {
                        print(error.localizedDescription)
                        await send(.view(.commentLikeResponseFailure(commentId: commentId, errorMessage: error.localizedDescription)))
                    }
                }
                
            case let .view(.didTappedCommentNotification(postId)):
                if var override = state.overrides[postId] {
                    let originalNotified = state.originalNotificationState[postId] ?? false
                    let currentNotified = override.isNotified ?? originalNotified
                    override.isNotified = !currentNotified
                    state.overrides[postId] = override
                } else {
                    let originalNotified = state.originalNotificationState[postId] ?? false
                    state.overrides[postId] = PostLocalOverride(
                        isLiked: nil,
                        likeCountDelta: 0,
                        isScrapped: nil,
                        isNotified: !originalNotified
                    )
                }
                
                applyOverrides(to: &state)
                return .run { send in
                    do {
                        let postId = String(postId)
                        try await updateCommentNotificationUseCase.execute(postId: postId)
                        await send(.view(.commentNotificationSuccess(postId: Int(postId) ?? 0)))
                    } catch {
                        print(error.localizedDescription)
                        await send(.view(.commentNotificationFailure(postId: Int(postId) ?? 0, errorMessage: error.localizedDescription)))
                    }
                }
                
            case let .view(.didTappedScrap(postId)):
                let originalScrapped = state.originalScrapState[postId] ?? false
                
                if var override = state.overrides[postId] {
                    let currentScrapped = override.isScrapped ?? originalScrapped
                    override.isScrapped = !currentScrapped
                    state.overrides[postId] = override
                } else {
                    state.overrides[postId] = PostLocalOverride(
                        isLiked: nil,
                        likeCountDelta: 0,
                        isScrapped: !originalScrapped,
                        isNotified: nil
                    )
                }
                applyOverrides(to: &state)
                return .run { send in
                    do {
                        try await updatePostDetailScrapUseCase.execute(postId: postId)
                        await send(.view(.scrapResponseSuccess(postId: postId)))
                    } catch {
                        await send(.view(.scrapResponseFailure(postId: postId, errorMessage: error.localizedDescription)))
                    }
                }
                
            case .view(.likeResponseSuccess(postId: let postId)):
                return .none
                
            case .view(.likeResponseFailure(postId: let postId, errorMessage: let errorMessage)):
                if var override = state.overrides[postId] {
                    let originalLiked = state.originalLikeState[postId] ?? false
                    
                    if let currentLiked = override.isLiked {
                        override.isLiked = !currentLiked
                        
                        if originalLiked {
                            override.likeCountDelta = override.isLiked == true ? 0 : -1
                        } else {
                            override.likeCountDelta = override.isLiked == true ? 1 : 0
                        }
                        
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
                
                
            case .view(.scrapResponseSuccess(postId: let postId)):
                return .none
                
            case .view(.scrapResponseFailure(postId: let postId, errorMessage: let errorMessage)):
                if var override = state.overrides[postId] {
                    if let currentScrapped = override.isScrapped {
                        override.isScrapped = !currentScrapped
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
            case .view(.commentNotificationSuccess(postId: let postId)):
                return .none
            case .view(.commentNotificationFailure(postId: let postId, errorMessage: let errorMessage)):
                if var override = state.overrides[postId] {
                    if let currentNotified = override.isNotified {
                        override.isNotified = !currentNotified
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
            case .inner(.postCommentResponse(.success(let comment))):
                state.commentItem = comment
                state.originalComments = comment
                print("값 확인 합니다 : \(state.commentItem)")
                return .none
            case let .inner(.postCommentResponse(.failure)):
                return .none
            case .view(.didTappedChat):
                state.isShowingChatTextField = true
                return .none
                
            case .view(.dismissChatTextField):
                state.isShowingChatTextField = false
                state.chatInputText = ""
                return .none
                
            case let .view(.didTappedSendChat(postId, message)):
                state.isShowingChatTextField = false
                state.chatInputText = ""

                print("댓글 답니다 : \(message) \(postId)")
                let pendingComment = CommentEntity(
                    id: 0,
                    isMine: true,
                    profileImageURL: nil,
                    nickname: "익명의 글쓴이",
                    content: message,
                    likeCount: 0,
                    isLiked: false,
                    isReported: false,
                    createdAt: Date().toCustomFormatRelative()
                )
                
                state.pendingComments.append(pendingComment)
                
                return .run { send in
                    do {
                        let body = CreatePostCommentRequest(postId: postId, content: message)
                        let success = try await createPostCommentUseCase.execute(body: body)
                        await send(.inner(.createCommentFinished(.success(success))))
                    } catch {
                        await send(.inner(.createCommentFinished(.failure(error))))
                    }
                }
                
            case let .view(.chatInputTextChanged(text)):
                state.chatInputText = text
                return .none
            case let .inner(.createCommentFinished(result)):
                switch result {
                case .success:
                    if !state.pendingComments.isEmpty {
                        state.pendingComments.removeLast()
                    }

                    let commentQuery = FetchCommentRequestQuery(postId: state.postId)
                    return .run { send in
                        do {
                            let comments = try await fetchCommentItemUseCase.execute(commentQuery)
                            await send(.inner(.postCommentResponse(.success(comments))))
                        } catch {
                            await send(.inner(.postCommentResponse(.failure(error))))
                        }
                    }

                case .failure:
                    if !state.pendingComments.isEmpty {
                        state.pendingComments.removeLast()
                    }
                    return .none
                }
            case .view(.commentLikeResponseSuccess(commentId: let commentId)):
                let commentQuery = FetchCommentRequestQuery(postId: state.postId)
                return .run { send in
                    do {
                        let comments = try await fetchCommentItemUseCase.execute(commentQuery)
                        await send(.inner(.postCommentResponse(.success(comments))))
                        await send(.inner(.clearCommentOverride(commentId: commentId)))
                    } catch {
                        await send(.inner(.postCommentResponse(.failure(error))))
                    }
                }
                
            case .view(.commentLikeResponseFailure(commentId: let commentId, errorMessage: let errorMessage)):
                if let override = state.commentLikeOverrides[commentId] {
                    let currentLiked = override.isLiked
                    let originalComment = state.originalComments.first(where: { String($0.id) == commentId })
                    let originalLiked = originalComment?.isLiked ?? false
                    
                    if originalLiked == !currentLiked {
                        state.commentLikeOverrides[commentId] = CommentLikeOverride(
                            isLiked: !currentLiked,
                            likeCountDelta: originalLiked ? -override.likeCountDelta : -override.likeCountDelta
                        )
                    } else {
                        state.commentLikeOverrides.removeValue(forKey: commentId)
                    }
                }
                                    return .none
            case .inner(.clearCommentOverride(commentId: let commentId)):
                state.commentLikeOverrides.removeValue(forKey: commentId)
                return .none
            }
        }
    }
}


extension FeedDetailFeature {
    func applyOverrides(to state: inout State) {
        guard let rawPost = state.rawPostListItems else {
            state.postEntity = nil
            return
        }
        
        if state.originalPostData == nil {
            state.originalPostData = rawPost
        }
        
        guard let originalPost = state.originalPostData,
              let originalContent = originalPost.content else {
            state.postEntity = rawPost
            return
        }
        
        guard let override = state.overrides[originalPost.id] else {
            state.postEntity = originalPost
            return
        }
        
        var updatedPost = originalPost
        var newFooter = originalContent.footer
        
        if let isScrapped = override.isScrapped {
            let old = newFooter.scrap
            newFooter.scrap = Scrap(
                iconURL: old.iconURL,
                iconColor: old.iconColor,
                selected: isScrapped
            )
        }
        
        if let isLiked = override.isLiked,
           let likeIdx = newFooter.reactions.firstIndex(where: { $0.type == "Like" }) {
            var like = newFooter.reactions[likeIdx]
            
            let originalLikeCount = Int(originalContent.footer.reactions[likeIdx].count.text.replacingOccurrences(of: ",", with: "")) ?? 0
            let adjustedCount = originalLikeCount + override.likeCountDelta
            
            like.selected = isLiked
            like.count = StyledText(
                text: "\(max(0, adjustedCount))",
                color: like.count.color,
                typography: like.count.typography,
                maxLine: like.count.maxLine
            )
            newFooter.reactions[likeIdx] = like
        }
        
        var newHeader = originalContent.header
        if let isNotified = override.isNotified,
           var button = originalContent.header.button {
            button.isSelected = isNotified
            newHeader = HeaderEntity(
                profileImageURL: originalContent.header.profileImageURL,
                profileImageWidth: originalContent.header.profileImageWidth,
                profileImageHeight: originalContent.header.profileImageHeight,
                nickname: originalContent.header.nickname,
                createdAt: originalContent.header.createdAt,
                category: originalContent.header.category,
                button: button
            )
        }
        
        let newContent = PostContent(
            category: originalContent.category,
            header: newHeader,
            info: originalContent.info,
            contentSection: originalContent.contentSection,
            footer: newFooter,
            button: originalContent.button
        )
        
        updatedPost = PostItem(
            id: updatedPost.id,
            type: updatedPost.type,
            content: newContent,
            isMyPost: updatedPost.isMyPost ?? false
        )
        
        state.postEntity = updatedPost
    }
}
