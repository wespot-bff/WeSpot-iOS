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
import Storage

@ViewAction(for: PostWriteFeature.self)
struct PostWriteView: View {
    @Perception.Bindable var store: StoreOf<PostWriteFeature>
    @StateObject private var viewStore: ViewStore<PostWriteFeature.State, PostWriteFeature.Action>
    @FocusState private var isTextFieldFocused: Bool
    @State private var images: [UIImage] = []
    @State private var localPhotoItems: [PhotosPickerItem] = []
    @State private var showAlertView = false
    @State private var showCategoryMain = false
    @State private var isShowingWriteSheet = false
    @State private var shouldShowCategorySheet = false
    @State private var showCloseAlert = false
    @Environment(\.presentationMode) private var presentationMode
    
    public init(store: StoreOf<PostWriteFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    var body: some View {
        WithPerceptionTracking {
            
            NavigationLink(
                 destination: CategoryMainView(
                     store: .init(
                         initialState: CategoryMainFeature.State(
                             category: viewStore.selectedCategory,
                             isEditable: true
                         ),
                         reducer: {CategoryMainFeature()}
                     )
                 ),
                 isActive: $showCategoryMain,
                 label: { EmptyView()}
             )
            
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
                    .wsNavigationBar(
                        left: { EmptyView() },
                        title: {
                            Text("게시글 작성")
                                .foregroundStyle(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        },
                        right: {
                            Button {
                                showAlertView = true
                            } label: {
                                DesignSystemAsset.Images.icCommunityXmarkFiled.swiftUIImage
                            }
                        }
                    )
                }
                .customAlert(
                    isPresented: $showAlertView,
                    title: "게시글 수정을 중단하시나요?",
                    message: "작성 중인 내용은 삭제되고 되돌릴 수 없어요",
                    primaryButtonText: "네",
                    secondaryButtonText: "아니오",
                    style: .normal,
                    primaryAction: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                .onChange(of: viewStore.didUploadSuccess) { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
                        onWriteComplete()
                        NotificationCenter.default.post(name: .didFinishWritePost, object: nil)
                    }
                }
                .onChange(of: shouldShowCategorySheet) { shouldShow in
                    if shouldShow {
                        viewStore.send(.view(.didTappedCategoryButton))
                        shouldShowCategorySheet = false
                    }
                }
                .onAppear {
                    NotificationCenter.default.post(name: .hideTabBar, object: nil)
                    checkFirstTimeWrite()
                    if let urls = viewStore.editingPost?.content?.contentSection?.imageURLs, viewStore.uiImages.isEmpty {
                        Task {
                            var loadedImages: [UIImage] = []
                            for url in urls {
                                if let data = try? Data(contentsOf: URL(string: url) ?? URL(fileURLWithPath: "")), let image = UIImage(data: data) {
                                    loadedImages.append(image)
                                }
                            }
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
            HStack(spacing: 24) {
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
        .sheet(isPresented: $isShowingWriteSheet, content: {
            HealthyCommunicationView(onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shouldShowCategorySheet = true
                }
            })
            .presentationCornerRadius(25)
            .presentationDetents([.height(423)])
            .interactiveDismissDisabled(true)
        })
        .sheet(isPresented: viewStore.binding(get: \.isShowingCategorySheet, send: { $0 ? .view(.didTappedCategoryButton) : .view(.dismissCategorySheet) })) {
            CategoryBottomSheetView(
                sections: viewStore.chipDetails,
                onSelect: { chip in viewStore.send(.view(.didSelectChip(chip))) }, selectedCategoryId: viewStore.selectedCategory?.id ?? 0
            )
            .presentationCornerRadius(25)
            .presentationDetents([.height(423)])
            .ignoresSafeArea(.all)
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
                let _ = print("상태값 확인 : \(viewStore.descriptionTooLong)")
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
        VStack(alignment: .leading, spacing: 8) {
            Text("(선택) 사진 올리기")
                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
            Text("사진은 3장까지 올릴 수 있어요")
                .foregroundStyle(DesignSystemAsset.Colors.gray400.swiftUIColor)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                .padding(.bottom, 10)
            
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
                                    .background(Circle().fill(Color.gray.opacity(0.8)))
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
        Button(action: {
            viewStore.send(.view(.submitButtonTapped))
        }) {
            if viewStore.isSubmitting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystemAsset.Colors.gray900.swiftUIColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("게시하기")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundColor(viewStore.canSubmit ? DesignSystemAsset.Colors.gray900.swiftUIColor : DesignSystemAsset.Colors.gray300.swiftUIColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundColor(.white)
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
            .frame(height: 240)
            .padding(.bottom, 8)
        }
    }
}


struct HealthyCommunicationView: View {
    @Environment(\.dismiss) private var dismiss
    let onDismiss: () -> Void
    var body: some View {
        ZStack {
            DesignSystemAsset.Colors.gray600.swiftUIColor
                .ignoresSafeArea(.all)
            
            VStack {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text("위스팟은 건강한 소통을 지향해요")
                            .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 20))
                            .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                            .padding(.bottom, 34)
                        
                        VStack(spacing: 32) {
                            GuidelineRow(
                                emoji: DesignSystemAsset.Images.icCommunitySadFaceFiled.swiftUIImage,
                                text: "욕설, 모욕, 저격 등 타인의 명예를 훼손하거나\n과도하게 비방하는 행위는 허용하지 않아요."
                            )
                            
                            GuidelineRow(
                                emoji: DesignSystemAsset.Images.icCommunityMoneyFiled.swiftUIImage,
                                text: "개인의 아이, 수익을 목적으로 한 도배/광고성\n게시글은 허용하지 않아요."
                            )
                            
                            GuidelineRow(
                                emoji: DesignSystemAsset.Images.icCommunityLaughFiled.swiftUIImage,
                                text: "신고 차단 기능을 활용하여 건강하고 즐거운\n소통 문화 형성에 동참해주세요."
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 34)
                        .padding(.bottom, 40)
                        
                        Button(action: {
                            dismiss()
                            onDismiss()
                        }) {
                            Text("이해했어요")
                                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(DesignSystemAsset.Colors.primary300.swiftUIColor)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        
                    }
                }
            }
        }
    }
}

struct GuidelineRow: View {
    let emoji: Image
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            emoji
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}


extension PostWriteView {
    func checkFirstTimeWrite() {
        let hasWrittenBefore = KeychainManager.shared.getBool(type: .isFeedWrite)
        print("작성한 플래그 값 확인합니다 : \(hasWrittenBefore)")
        
        if !hasWrittenBefore {
            DispatchQueue.main.async {
                isShowingWriteSheet = true
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shouldShowCategorySheet = true
            }
        }
    }

    func onWriteComplete() {
        KeychainManager.shared.set(value: true, type: .isFeedWrite)
        isShowingWriteSheet = false
    }
}
