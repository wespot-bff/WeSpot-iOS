//
//  PostWriteFeature.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/26/25.
//

import ComposableArchitecture
import DesignSystem
import CommunityDomain
import CommunityService
import _PhotosUI_SwiftUI
import Util


@Reducer
public struct PostWriteFeature {
    @Dependency(\.fetchCategoryDetailItemUseCase) var fetchCategoryDetailUseCase: FetchCategoryDetailItemUseCaseProtocol
    @Dependency(\.uploadPostItemUseCase) var uploadPostItemUseCase: UploadPostItemUseCaseProtocol
    @Dependency(\.fetchPostImagePresignedURLUseCase) var fetchPostImagePresignedURLUseCase: FetchPostImagePresignedURLUseCaseProtocol
    @Dependency(\.uploadPostImageItemUseCase) var uploadPostImageItemUseCase: UploadPostImageItemUseCaseProtocol
    
    // MARK: – State
    @ObservableState
    public struct State: Equatable {
        var chipDetails: [CategoryDetailEntity] = []
        var isShowingCategorySheet = false
        var selectedCategory: CategoryChipsEntity? = nil
        var didUploadSuccess = false
        var postTitle: String = ""
        var postDescription: String = ""
        var uiImages: [UIImage] = []
        var photoItems: [PhotosPickerItem] = []
        var photoImageData: [Data] = []
        var uploadImageRequests: [UploadPostImageItemReqeuest] = []
        var preSignedURLEntity: [CreatePostImagePresignedURLEntity] = []
    }
    
    // MARK: – Action
    public enum Action: ViewAction {
        case view(View)
        case inner(Inner)
        case binding(BindingAction<State>)
        case `internal`(Internal)
    }
    
    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        
        case onAppear
        case didTappedCategoryButton
        case submitButtonTapped
        case dismissCategorySheet
        case didSelectChip(CategoryChipsEntity)
        case titleChanged(String)
        case descriptionChanged(String)
        case onPhotosChanged([PhotosPickerItem])
    }
    
    public enum Internal {
        case postUploadResponse(Bool)
    }
    
    public enum Inner {
        case photosLoaded([UIImage],[Data], [CreatePostImagePresignedURLEntity])
        case detailsResponse(TaskResult<[CategoryDetailEntity]>)
    }
    
    public init() {} 
    
    // MARK: – Reducer
    public var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .none
            case .view(.onPhotosChanged(let newItems)):
                state.photoItems = newItems
                
                return .run { send in
                    var uiImgs: [UIImage] = []
                    var bianryData: [Data] = []
                    var presignedURL: [CreatePostImagePresignedURLEntity] = []
                    for item in newItems.prefix(3) {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image  = UIImage(data: data)
                        {
                            
                            let presigned = try await fetchPostImagePresignedURLUseCase
                                .execute(query: .init(imageExtension: "jpeg"))
                            
                            presignedURL.append(presigned)
                            uiImgs.append(image)
                            bianryData.append(data)
                        }
                    }
                    await send(.inner(.photosLoaded(uiImgs, bianryData, presignedURL)))
                }
            case .inner(.photosLoaded(let imgs, let photoImageData, let presignedURL)):
                state.uiImages = imgs
                state.photoImageData = photoImageData
                state.preSignedURLEntity = presignedURL
                return .none
                
            case .view(.submitButtonTapped):
                
                guard let category = state.selectedCategory else { return .none }
                let categoryId   = category.id
                let title        = state.postTitle
                let description  = state.postDescription
                let presignedList  = state.preSignedURLEntity
                let imageDataList       = state.photoImageData
                return .run { send in
                    do {
                        for (data, presigned) in zip(imageDataList, presignedList) {
                            let ok = try await uploadPostImageItemUseCase.execute(
                                data,
                                presigendURL: presigned.presignedURL
                            )
                            guard ok else {
                                throw URLError(.badServerResponse)
                            }
                        }
                        let imageRequests = presignedList.map { presigned in
                            UploadPostImageItemReqeuest(url: presigned.imageURL, width: 0, height: 0)
                        }
                        
                        
                        let body = UploadPostItemRequest(
                            categoryId: categoryId,
                            title: title,
                            description: description,
                            imagesRequest: imageRequests
                        )
                        
                        let success = try await uploadPostItemUseCase.execute(body: body)
                        await send(.internal(.postUploadResponse(success)))
                    } catch {
                        await send(.internal(.postUploadResponse(false)))
                    }
                }
            case .view(.didTappedCategoryButton):
                state.isShowingCategorySheet = true
                return .run { send in
                    async let detailsUseCase = fetchCategoryDetailUseCase.execute()
                    do {
                        let detailsResponse = try await detailsUseCase
                        await send(.inner(.detailsResponse(.success(detailsResponse))))
                    } catch {
                        await send(.inner(.detailsResponse(.failure(error))))
                    }
                }
                
            case .view(.dismissCategorySheet):
                state.isShowingCategorySheet = false
                return .none
                
            case .view(.didSelectChip(let chip)):
                state.selectedCategory = chip
                state.isShowingCategorySheet = false
                return .none
                
            case .view(.titleChanged(let postTitle)):
                state.postTitle = postTitle
                return .none
                
            case .view(.descriptionChanged(let postDescription)):
                state.postDescription = postDescription
                return .none
                
            case .view(.binding):
                return .none
                
            case .inner(.detailsResponse(.failure)):
                return .none
            case .inner(.detailsResponse(.success(let chipDetails))):
                state.chipDetails = chipDetails
                return .none
                
            case .binding:
                return .none
            case let .internal(.postUploadResponse(success)):
                print("게시글 업로드 성공 여부 값 입니다 : \(success)")
                if success {
                  state.didUploadSuccess = true
                }
                return .none
            }
        }
    }
}
