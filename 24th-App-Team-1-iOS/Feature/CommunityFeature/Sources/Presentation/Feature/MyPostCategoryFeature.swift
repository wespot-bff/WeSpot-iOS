//
//  MyPostCategoryFeature.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/7/25.
//

import ComposableArchitecture
import CommunityService
import CommunityDomain

@Reducer
public struct MyPostCategoryFeature {
    @Dependency(\.fetchMyScrapItemUseCase) var fetchMyScrapItemUseCase: FetchMyScrapItemUseCaseProtocol
    @Dependency(\.fetchMyPostCommnetItemUseCase) var fetchMyPostCommnetItemUseCase: FetchMyPostCommnetItemUseCaseProtocol
    @Dependency(\.fetchMyPostWrittenItemUseCase) var fetchMyPostWrittenItemUseCase: FetchMyPostWrittenItemUseCaseProtocol
    
    
    @ObservableState
    public struct State: Equatable {
        var postListItems: PostListEntity?
        var category: MyCategoryType
        
        
        public init(category: MyCategoryType) {
            self.category = category
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
    }
    
    
    public enum Inner {
        case postListResponse( TaskResult<PostListEntity> )
    }
    
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
          switch action {
          case .view(.onAppear):
            let category = state.category

            return .run { send in
              do {
                let posts: PostListEntity
                switch category {
                case .scrap:
                  posts = try await fetchMyScrapItemUseCase.execute()
                case .written:
                  posts = try await fetchMyPostWrittenItemUseCase.execute()
                case .comment:
                  posts = try await fetchMyPostCommnetItemUseCase.execute()
                }
                await send(.inner(.postListResponse(.success(posts))))
              } catch {
                await send(.inner(.postListResponse(.failure(error))))
              }
            }

          case .inner(.postListResponse(.success(let list))):
            state.postListItems = list
            return .none

          case .inner(.postListResponse(.failure)):
            return .none

          case .view(.binding):
            return .none

          case .binding:
            return .none
          }
        }
      }
}
