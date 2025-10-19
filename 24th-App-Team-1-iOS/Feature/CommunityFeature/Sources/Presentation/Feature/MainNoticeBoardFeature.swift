//
//  MainNoticeBoardFeature.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/29/25.
//

import ComposableArchitecture
import CommunityDomain
import CommunityService


@Reducer
public struct MainNoticeBoardFeature {
    @Dependency(\.fetchCategoryItemUseCase) var fetchCategoryItemUseCase: FetchCategoryItemUseCaseProtocol
    @Dependency(\.fetchPostAllItemListUseCase) var fetchPostItemListUseCase: FetchPostAllItemUseCaseProtocol
    @Dependency(\.fetchPostItemListUseCase) var fetchPostDetailListUseCase: FetchPostItemListUseCaseProtocol
    @Dependency(\.updatePostScrapUseCase) var updatePostScrapUseCase: UpdatePostScrapUseCaseProtocol
    @Dependency(\.updatePostLikeUseCase) var updatePostLikeUseCase: UpdatePostLikeUseCaseProtocol
    @Dependency(\.fetchCategoryDetailItemUseCase) var fetchCategoryDetailUseCase: FetchCategoryDetailItemUseCaseProtocol
    
    
    
    @ObservableState
    public struct State: Equatable {
        var filterChips: [FilterChipEntity] = []
        var postListItems: PostListEntity? = nil
        var rawPostListItems: PostListEntity? = nil
        var selectedChip: FilterChipEntity? = nil
        var isScrap: Bool = false
        var isLike: Bool = false
        var overrides: [Int: PostLocalOverride] = [:]
        var isShowingCategorySheet: Bool = false
        var chipDetails: [CategoryDetailEntity] = []
        var selectedCategory: CategoryChipsEntity? = nil
        var isLoadingPage = false
        var nextCursor: Int? = nil
        var hasNext: Bool = false
        
        public init(filterChips: [FilterChipEntity] = [], postListItems: PostListEntity? = nil) {
            self.filterChips = filterChips
            self.postListItems = postListItems
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case inner(Inner)
        case binding(BindingAction<State>)
        case `internal`(Internal)
    }
    
    @CasePathable
    public enum View: BindableAction, Equatable {
        case loadNextPage
        case binding(BindingAction<State>)
        case didTappedCategoryButton
        case didSelectDetailChip(CategoryChipsEntity)
        case didSelectChip(FilterChipEntity)
        case didTappedLike(Int)
        case didTappedScrap(Int)
        case dismissCategorySheet
        case likeResponseSuccess(postId: Int)
        case likeResponseFailure(postId: Int, errorMessage: String)
        case scrapResponseSuccess(postId: Int)
        case scrapResponseFailure(postId: Int, errorMessage: String)
        case onAppear
    }
    
    
    public enum Internal {
        
    }
    
    public enum Inner {
        case filterChipsResponse(TaskResult<[FilterChipEntity]>)
        case postListResponse( TaskResult<PostListEntity>,  isLoadMore: Bool)
        case detailsResponse(TaskResult<[CategoryDetailEntity]>)
    }
    
    public init() {}
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                print("메인 화면 호출 appear")
                state.nextCursor = nil
                state.hasNext = false
                state.rawPostListItems = nil
                state.postListItems = nil
                state.selectedChip = nil
                
                return .run { send in
                    let query = FetchPostAllItemRequestQuery(majorCategoryName: "", inquirySize: 10)
                    async let chips = fetchCategoryItemUseCase.execute()
                    async let posts = fetchPostItemListUseCase.execute(query:query)
                    do {
                        let (chips, posts) = try await (chips, posts)
                        await send(.inner(.filterChipsResponse(.success(chips))))
                        await send(.inner(.postListResponse(.success(posts), isLoadMore: false)))
                    } catch {
                        await send(.inner(.filterChipsResponse(.failure(error))))
                        await send(.inner(.postListResponse(.failure(error), isLoadMore: false)))
                    }
                }
                
            case .view(.didTappedCategoryButton):
                state.isShowingCategorySheet = true
                return .run { send in
                    async let detailUsecase = fetchCategoryDetailUseCase.execute()
                    do {
                        let detailsResponse = try await detailUsecase
                        await send(.inner(.detailsResponse(.success(detailsResponse))))
                    } catch {
                        await send(.inner(.detailsResponse(.failure(error))))
                    }
                    
                }
                
            case .view(.dismissCategorySheet):
                state.isShowingCategorySheet = false
                return .none
                
            case .view(.didSelectDetailChip(let chip)):
                
                state.selectedCategory = chip
                state.isShowingCategorySheet = false
                
                state.nextCursor = nil
                state.hasNext = false
                state.rawPostListItems = nil
                
                return .run { send in
                    let query = FetchPostDetailItemRequestQuery(categoryId: chip.id, inquirySize: 10, cursorId: 10)
                    async let postsUsecase = fetchPostDetailListUseCase.execute(query: query)

                    do {
                        let posts = try await postsUsecase
                        await send(.inner(.postListResponse(.success(posts), isLoadMore: false)))
                    } catch {
                        await send(.inner(.postListResponse(.failure(error), isLoadMore: false)))
                    }
                }

            case .view(.binding):
                return .none
                
            case .inner(.filterChipsResponse(.success(let chips))):
                state.filterChips = chips

                if state.selectedChip == nil {
                    if let allCateogory = chips.first(where: { $0.text == "전체" }) {
                        state.selectedChip = allCateogory
                        return .run { send in
                            let query = FetchPostAllItemRequestQuery(majorCategoryName: allCateogory.text, inquirySize: 20)
                            do {
                                let posts = try await fetchPostItemListUseCase.execute(query: query)
                                await send(.inner(.postListResponse(.success(posts), isLoadMore: false)))
                            } catch {
                                await send(.inner(.postListResponse(.failure(error), isLoadMore: false)))
                            }
                        }
                    }
                }
                return .none
                
            case .inner(.filterChipsResponse(.failure)):
                return .none
                
                
                
            case .inner(.postListResponse(.success(let posts), let isLoadMore)):
                state.isLoadingPage = false
                
                state.nextCursor = posts.lastCursorId
                state.hasNext = posts.hasNext
                
                if isLoadMore {
                    if var raw = state.rawPostListItems {
                        raw.items += posts.items
                        raw.lastCursorId = posts.lastCursorId
                        raw.hasNext = posts.hasNext
                        state.rawPostListItems = raw
                    } else {
                        state.rawPostListItems = posts
                    }
                } else {
                    state.rawPostListItems = posts
                }
                
                applyOverrides(to: &state)
                return .none
                
                
            case .inner(.postListResponse(.failure, _)):
                
                return .none
                
            case .binding:
                return .none
            case let .view(.didSelectChip(chip)):
                state.selectedChip = chip
                state.nextCursor = nil
                state.hasNext = false
                state.rawPostListItems = nil
                state.postListItems = nil
                
                state.selectedChip = chip
                return .run { send in
                    let query = FetchPostAllItemRequestQuery(majorCategoryName: chip.text, inquirySize: 10, cursorId: nil)
                    do {
                        let posts = try await fetchPostItemListUseCase.execute(query: query)
                        await send(.inner(.postListResponse(.success(posts), isLoadMore: false)))
                    } catch {
                        await send(.inner(.postListResponse(.failure(error), isLoadMore: false)))
                    }
                }
            case .view(.scrapResponseFailure(let postId, _)):
                if var override = state.overrides[postId] {
                    if let isScrapped = override.isScrapped {
                        override.isScrapped = !isScrapped
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
                
                
            case .view(.likeResponseFailure(let postId, _)):
                if var override = state.overrides[postId] {
                    if let isLiked = override.isLiked {
                        override.isLiked = !isLiked
                        override.likeCountDelta += isLiked ? -1 : 1
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
                
            case .view(.didTappedLike(let postId)):
                if var override = state.overrides[postId] {
                    let wasLiked = override.isLiked ?? false
                    override.isLiked = !wasLiked
                    override.likeCountDelta += wasLiked ? -1 : 1
                    state.overrides[postId] = override
                } else {
                    state.overrides[postId] = PostLocalOverride(isLiked: true, likeCountDelta: 1, isScrapped: nil)
                }
                applyOverrides(to: &state)
                
                return .run { send in
                    do {
                        print("낙관적 업데이트 좋아요 ID : \(postId)")
                        try await updatePostLikeUseCase.execute(postId: postId)
                        await send(.view(.likeResponseSuccess(postId: postId)))
                    } catch {
                        await send(.view(.likeResponseFailure(postId: postId, errorMessage: error.localizedDescription)))
                    }
                }
                
            case .view(.didTappedScrap(let postId)):
                if var override = state.overrides[postId] {
                    if let current = override.isScrapped {
                        override.isScrapped = !current
                    } else {
                        override.isScrapped = true
                    }
                    state.overrides[postId] = override
                } else {
                    state.overrides[postId] = PostLocalOverride(isLiked: nil, likeCountDelta: 0, isScrapped: true)
                }
                applyOverrides(to: &state)
                
                return .run { send in
                    do {
                        try await updatePostScrapUseCase.execute(postId: postId)
                        await send(.view(.scrapResponseSuccess(postId: postId)))
                    } catch {
                        await send(.view(.scrapResponseFailure(postId: postId, errorMessage: error.localizedDescription)))
                    }
                }
            case .view(.likeResponseSuccess(postId: let postId)):
                return .none
            case .view(.scrapResponseSuccess(postId: let postId)):
                return .none
            case .inner(.detailsResponse(.failure)):
                return .none
            case .inner(.detailsResponse(.success(let chipDetails))):
                state.chipDetails = chipDetails
                return .none
            case .view(.loadNextPage):
                guard !state.isLoadingPage, state.hasNext else { return .none }
                state.isLoadingPage = true

              let query = FetchPostAllItemRequestQuery(
                majorCategoryName: state.selectedChip?.text ?? "",
                inquirySize: 20,
                cursorId: state.nextCursor
              )

              return .run { send in
                do {
                  let response = try await fetchPostItemListUseCase.execute(query: query)
                    await send(.inner(.postListResponse(.success(response), isLoadMore: true)))
                } catch {
                    await send(.inner(.postListResponse(.failure(error), isLoadMore: true)))
                }
              }
            }
        }
    }
}


extension MainNoticeBoardFeature {
    
    func applyOverrides(to state: inout State) {
        guard let raw = state.rawPostListItems else {
            state.postListItems = nil
            return
        }
        var merged = raw
        
        for (index, element) in merged.items.enumerated() {
            if case .post(var post) = element, let content = post.content {
                if let override = state.overrides[post.id] {
                    var newFooter = content.footer
                    
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
                        let baseCount = Int(like.count.text.replacingOccurrences(of: ",", with: "")) ?? 0
                        let adjustedCount = baseCount + override.likeCountDelta
                        like.selected = isLiked
                        like.count = StyledText(
                            text: "\(max(0, adjustedCount))",
                            color: like.count.color,
                            typography: like.count.typography,
                            maxLine: like.count.maxLine
                        )
                        newFooter.reactions[likeIdx] = like
                    }
                    
                    let newContent = PostContent(
                        category: content.category,
                        header: content.header,
                        info: content.info,
                        contentSection: content.contentSection,
                        footer: newFooter,
                        button: content.button
                    )
                    post = PostItem(id: post.id, type: post.type, content: newContent)
                    merged.items[index] = .post(post)
                }
            }
        }
        state.postListItems = merged
    }
    
}
