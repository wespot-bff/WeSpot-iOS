//
//  PostWriteView.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/22/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import _PhotosUI_SwiftUI
import CommunityDomain
import Perception

@ViewAction(for: PostWriteFeature.self)
struct PostWriteView: View {
    @Perception.Bindable var store: StoreOf<PostWriteFeature>
    @StateObject private var viewStore: ViewStore<PostWriteFeature.State, PostWriteFeature.Action>
    @FocusState private var isTextFieldFocused: Bool
    @State private var images: [UIImage] = []
    @State private var localPhotoItems: [PhotosPickerItem] = []
    @State private var showAlertView = false
    @Environment(\.presentationMode) private var presentationMode
    
    public init(store: StoreOf<PostWriteFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    var body: some View {
        WithPerceptionTracking {
            GeometryReader { geo in
                let topInset = geo.safeAreaInsets.top
                let navBarHeight = topInset + 8 + 44 + 12
                
                ZStack(alignment: .top) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            Color.clear.frame(height: navBarHeight)
                            
                            categorySection
                            titleSection
                            descriptionSection
                            imageSection
                            submitSection
                        }
                    }
                    .onTapGesture { isTextFieldFocused = false }
                    .customAlert(
                        isPresented: $showAlertView,
                        title: "게시글 수정을 중단할까요?",
                        message: "작성한 내용이 사라져요.",
                        primaryButtonText: "네",
                        secondaryButtonText: "아니오",
                        style: .normal,
                        primaryAction: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .wsNavigationBar(
                        left: { EmptyView() },
                        title: {
                            Text("게시글 작성")
                                .foregroundStyle(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        },
                        right: {
                            Button {
                                if viewStore.isEditing == true {
                                    showAlertView = true
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } label: {
                                DesignSystemAsset.Images.icCommunityXmarkFiled.swiftUIImage
                            }
                        }
                    )
                }
                .onChange(of: viewStore.didUploadSuccess) {
                    if $0 {
                        presentationMode.wrappedValue.dismiss() }
                }
                .onAppear {
                    NotificationCenter.default.post(name: .hideTabBar, object: nil)
                    if let urls = viewStore.editingPost?.content?.contentSection?.imageURLs, viewStore.uiImages.isEmpty {
                        Task {
                            var loadedImages: [UIImage] = []
                            for url in urls {
                                if let data = try? Data(contentsOf: URL(string: url) ?? URL(fileURLWithPath: "")), let image = UIImage(data: data) {
                                    loadedImages.append(image)
                                }
                            }
                            print("🔍 View onAppear - imageURLs 개수: \(viewStore.imageURLs.count)")
                            print("🔍 View onAppear - imageURLs: \(viewStore.imageURLs)")
                            viewStore.send(.view(.setLoadedImages(loadedImages)))
                        }
                    }
                    
                }
            }
            .transparentScrolling()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        }
    }
    
    private var categorySection: some View {
        Button(action: { viewStore.send(.view(.didTappedCategoryButton)) }) {
            HStack(spacing: 12) {
                Text(viewStore.selectedCategory?.text ?? "카테고리 선택")
                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .frame(width: 167, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystemAsset.Colors.gray700.swiftUIColor)
            )
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: viewStore.binding(get: \.isShowingCategorySheet, send: { $0 ? .view(.didTappedCategoryButton) : .view(.dismissCategorySheet) })) {
            CategoryBottomSheetView(
                sections: viewStore.chipDetails,
                onSelect: { chip in viewStore.send(.view(.didSelectChip(chip))) }
            )
            .presentationCornerRadius(25)
            .presentationDetents([.height(423)])
        }
    }
    
    private var titleSection: some View {
        TextField("(선택) 제목을 입력해주세요", text: viewStore.binding(get: \.postTitle, send: { .view(.titleChanged($0)) }))
            .onChange(of: viewStore.postTitle) { if $0.count > 40 { viewStore.send(.view(.titleChanged(String($0.prefix(40))))) } }
            .focused($isTextFieldFocused)
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(DesignSystemAsset.Colors.gray700.swiftUIColor)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .foregroundColor(.white)
    }
    
    private var descriptionSection: some View {
        VStack(spacing: 4) {
            LimitedTextEditor(
                text: viewStore.binding(get: \.postDescription, send: { .view(.descriptionChanged($0)) }),
                placeholder: "어떤 생각을 하고 계신가요?\n학교 친구들과 함께 생각을 나눠보세요",
                maxLength: 1200
            )
            .focused($isTextFieldFocused)
            .padding(.horizontal, 20)
            
            HStack {
                if viewStore.descriptionTooLong {
                    Text("1200자 이내로 입력해 주세요.")
                        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        .foregroundColor(DesignSystemAsset.Colors.destructive.swiftUIColor)
                        .padding(.horizontal, 20)
                }
                Spacer()
                Text("\(viewStore.postDescription.count) / 1200")
                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                    .padding(.trailing, 20)
            }
        }
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("(선택) 사진 올리기")
                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
            Text("사진은 3장까지 올릴 수 있어요")
                .foregroundStyle(DesignSystemAsset.Colors.gray400.swiftUIColor)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    let totalImageCount = viewStore.uiImages.count
                    let remainingSlots = max(0, 3 - totalImageCount)
                    
                    
                    if remainingSlots > 0 {
                        PhotosPicker(
                            selection: $localPhotoItems,
                            maxSelectionCount: remainingSlots,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(DesignSystemAsset.Colors.gray600.swiftUIColor)
                                    .frame(width: 90, height: 90)
                                DesignSystemAsset.Images.icCommunityAddFiled.swiftUIImage
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                            }
                        }
                        .onChange(of: localPhotoItems) { newItems in
                            if !newItems.isEmpty {
                                viewStore.send(.view(.onPhotosChanged(newItems)))
                                localPhotoItems = []
                            }
                        }
                    }

                    ForEach(Array(viewStore.uiImages.enumerated()), id: \.offset) { idx, uiImage in
                        
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipped()
                                .cornerRadius(16)

                            Button {
                                viewStore.send(.view(.removeImage(at: idx)))
                            } label: {
                                DesignSystemAsset.Images.icCommunityXmarkWhiteFiled.swiftUIImage
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                                    .background(Circle().fill(Color.gray.opacity(0.6)))
                            }
                            .offset(x: 8, y: -8)
                        }
                        .frame(width: 90, height: 120)
                    }
                }
            }
            
        }
        .padding(.horizontal, 20)

    }

    
    
    private var submitSection: some View {
        Button(action: { viewStore.send(.view(.submitButtonTapped)) }) {
            Text("게시하기")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                .foregroundColor(viewStore.canSubmit ? DesignSystemAsset.Colors.gray900.swiftUIColor : DesignSystemAsset.Colors.gray300.swiftUIColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 52)
        .background(viewStore.canSubmit ? DesignSystemAsset.Colors.primary300.swiftUIColor : DesignSystemAsset.Colors.gray500.swiftUIColor)
        .disabled(!viewStore.canSubmit)
        .cornerRadius(12)
        .padding(.top, 37)
        .padding(.horizontal, 20)
    }
}


struct ImagePickerSection: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    let onImagesSelected: ([PhotosPickerItem]) -> Void
    let remainingSlots: Int
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: remainingSlots,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray)
                    .frame(width: 90, height: 90)
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onChange(of: selectedItems) { newItems in
            if !newItems.isEmpty {
                onImagesSelected(newItems)
                selectedItems = []
            }
        }
    }
}






struct LimitedTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let maxLength: Int
    
    init(text: Binding<String>, placeholder: String, maxLength: Int) {
        self._text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DesignSystemAsset.Colors.gray700.swiftUIColor)
                
                TextEditor(text: $text)
                    .padding(8)
                    .background(Color.clear)
                    .onChange(of: text) { new in
                        if new.count > maxLength {
                            text = String(new.prefix(maxLength))
                        }
                    }
                
                if text.isEmpty {
                    Text(placeholder)
                        .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
            .frame(height: 160)
            .padding(.bottom, 8)
        }
    }
}
