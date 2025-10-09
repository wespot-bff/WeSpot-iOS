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
    @Dependency(\.editPostItemUseCase) var editPostItemUseCase: EditPostItemUseCaseProtocol
    
    // MARK: – State
    @ObservableState
    public struct State: Equatable {
        var isEditing: Bool
        var chipDetails: [CategoryDetailEntity] = []
        var isShowingCategorySheet = false
        var selectedCategory: CategoryChipsEntity? = nil
        var didUploadSuccess = false
        var isMain: Bool
        var postTitle: String = ""
        var postDescription: String = ""
        var editingPost: PostItem? = nil
        var uiImages: [UIImage] = []
        var photoItems: [PhotosPickerItem] = []
        var photoImageData: [Data] = []
        var uploadImageRequests: [UploadPostImageItemReqeuest] = []
        var preSignedURLEntity: [CreatePostImagePresignedURLEntity] = []
        var imageURLs: [String] = []
        
        var titleTooLong: Bool {
            postTitle.count > 40
        }
        var descriptionTooLong: Bool {
            postDescription.count > 1200
        }
        var canSubmit: Bool {
            selectedCategory != nil
            && !postDescription.isEmpty
            && !descriptionTooLong
            && !titleTooLong
        }
        
        public init(editingPost: PostItem? = nil, selectedCategory: CategoryChipsEntity? = nil, isEditing: Bool = false, isMain: Bool = true) {
            self.editingPost = editingPost
            self.isEditing = isEditing
            self.isMain = isMain
            if selectedCategory != nil {
                self.selectedCategory = selectedCategory
            }
            
            if let post = editingPost {
                self.postTitle = post.content?.info.title?.text ?? ""
                self.postDescription = post.content?.info.description.text ?? ""
                if let category = post.content?.category {
                    self.selectedCategory = CategoryChipsEntity(id: Int(category.target) ?? 0, text: category.text)
                }
                self.imageURLs = post.content?.contentSection?.imageURLs ?? []
                print("이미지 URL 확인합니다 : \(self.imageURLs)")
            }
        }
        
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
        case onUIImageRemoved([UIImage])
        case onAppear
        case removeImage(at: Int)
        case didTappedCategoryButton
        case submitButtonTapped
        case dismissCategorySheet
        case didSelectChip(CategoryChipsEntity)
        case titleChanged(String)
        case descriptionChanged(String)
        case setLoadedImages([UIImage])
        case onPhotosChanged([PhotosPickerItem])
        case onImageURLsChanged([String])
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
            case .view(.setLoadedImages(let images)):

                let oldCount = state.uiImages.count
                let newCount = images.count
                
                state.uiImages = images
                
                if newCount < oldCount {
                    let removeCount = oldCount - newCount
                    for _ in 0..<removeCount {
                        if !state.preSignedURLEntity.isEmpty {
                            state.preSignedURLEntity.removeLast()
                        }
                        if !state.photoImageData.isEmpty {
                            state.photoImageData.removeLast()
                        }
                    }
                }
                
                
                return .none
                
            case let .view(.onImageURLsChanged(urls)):
                state.imageURLs = urls
                return .none
                
            case let .view(.onUIImageRemoved(images)):
                state.uiImages = images
                return .none
                
            case .view(.removeImage(let index)):
                guard index < state.uiImages.count else { return .none }

                state.uiImages.remove(at: index)

                if index < state.preSignedURLEntity.count {
                    state.preSignedURLEntity.remove(at: index)
                }

                if index < state.photoImageData.count {
                    state.photoImageData.remove(at: index)
                }

                if index < state.imageURLs.count {
                    state.imageURLs.remove(at: index)
                }

                return .none

                

            case .view(.onPhotosChanged(let newItems)):
                
                guard !newItems.isEmpty else {
                    return .none
                }
                
                return .run { [existingImageCount = state.uiImages.count] send in
                    var uiImgs: [UIImage] = []
                    var bianryData: [Data] = []
                    var presignedURL: [CreatePostImagePresignedURLEntity] = []
                    
                    let availableSlots = max(0, 3 - existingImageCount)
                    let itemsToProcess = Array(newItems.prefix(availableSlots))
                    
                    
                    for (index, item) in itemsToProcess.enumerated() {
                        do {
                            if let data = try await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                
                                let presigned = try await fetchPostImagePresignedURLUseCase
                                    .execute(query: .init(imageExtension: "jpeg"))
                                
                                presignedURL.append(presigned)
                                uiImgs.append(image)
                                bianryData.append(data)
                            }
                        } catch {
                            print(" 이미지 \(index) 에러: \(error)")
                        }
                    }
                    
                    await send(.inner(.photosLoaded(uiImgs, bianryData, presignedURL)))
                }

            case .inner(.photosLoaded(let imgs, let photoImageData, let presignedURL)):
                let currentCount = state.uiImages.count
                let maxAddable = max(0, 3 - currentCount)
                let imagesToAdd = Array(imgs.prefix(maxAddable))
                let dataToAdd = Array(photoImageData.prefix(maxAddable))
                let urlsToAdd = Array(presignedURL.prefix(maxAddable))
                
                
                state.uiImages.append(contentsOf: imagesToAdd)
                state.photoImageData.append(contentsOf: dataToAdd)
                state.preSignedURLEntity.append(contentsOf: urlsToAdd)
                
                
                return .none


                
            case .view(.submitButtonTapped):
                guard let category = state.selectedCategory else { return .none }
                let categoryId = category.id
                let title = state.postTitle
                let description = state.postDescription

                if state.isEditing {
                    guard let editingPost = state.editingPost else { return .none }
                    let postId = editingPost.id

                    let newPresignedList = state.preSignedURLEntity
                    let newImageDataList = state.photoImageData

                    let existingImageNames = state.imageURLs.compactMap {
                        URL(string: $0)?.lastPathComponent
                    }

                    return .run { send in
                        do {
                            for (data, presigned) in zip(newImageDataList, newPresignedList) {
                                let ok = try await uploadPostImageItemUseCase.execute(
                                    data,
                                    presigendURL: presigned.presignedURL
                                )
                                guard ok else { throw URLError(.badServerResponse) }
                            }

                            let newImageNames = newPresignedList.map { $0.imageName }

                            let allImageNames = existingImageNames + newImageNames

                            let body = UploadPostItemRequest(
                                categoryId: categoryId,
                                title: title,
                                description: description,
                                imagesRequest: allImageNames
                            )


                            let success = try await editPostItemUseCase.execute(postId: postId, body: body)
                            await send(.internal(.postUploadResponse(success)))
                        } catch {
                            await send(.internal(.postUploadResponse(false)))
                        }
                    }

                } else {
                    let presignedList = state.preSignedURLEntity
                    let imageDataList = state.photoImageData

                    return .run { send in
                        do {
                            for (data, presigned) in zip(imageDataList, presignedList) {
                                let ok = try await uploadPostImageItemUseCase.execute(
                                    data,
                                    presigendURL: presigned.presignedURL
                                )
                                guard ok else { throw URLError(.badServerResponse) }
                            }

                            let imageNames = presignedList.map { $0.imageName }

                            let body = UploadPostItemRequest(
                                categoryId: categoryId,
                                title: title,
                                description: description,
                                imagesRequest: imageNames
                            )


                            let success = try await uploadPostItemUseCase.execute(body: body)
                            await send(.internal(.postUploadResponse(success)))
                        } catch {
                            await send(.internal(.postUploadResponse(false)))
                        }
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
