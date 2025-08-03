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
    @Perception.Bindable
    var store: StoreOf<PostWriteFeature>
    @StateObject private var viewStore: ViewStore<PostWriteFeature.State, PostWriteFeature.Action>
    @FocusState private var isTextFieldFocused: Bool
    @State var text: String = ""
    @State private var content = ""
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []
    @Environment(\.presentationMode) private var presentationMode
    
    
    public init(store: StoreOf<PostWriteFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    var body: some View {
        WithPerceptionTracking {
            GeometryReader { geo in
                let topInset     = geo.safeAreaInsets.top
                let navBarHeight = topInset + 8 + 44 + 12
                ZStack(alignment: .top) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            Color.clear
                                .frame(height: navBarHeight)
                            Button(action: {
                                viewStore.send(.view(.didTappedCategoryButton))
                            }) {
                                HStack(spacing: 12) {
                                    let _ = print("데이터 왜이럼? \(viewStore.selectedCategory?.text)")
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
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(DesignSystemAsset.Colors.gray700.swiftUIColor)
                                )
                            }
                            .padding(.horizontal, 20)
                            .sheet(
                                isPresented: viewStore.binding(
                                    get: \.isShowingCategorySheet,
                                    send: { $0 ? .view(.didTappedCategoryButton) : .view(.dismissCategorySheet) }
                                )
                            ) {
                                CategoryBottomSheetView(
                                    sections: viewStore.chipDetails,
                                    onSelect: { chip in
                                        let _ = print("데이터 확인 \(chip)")
                                        viewStore.send(.view(.didSelectChip(chip)))
                                    }
                                )
                                .presentationCornerRadius(25)
                                .presentationDetents([.height(423)])
                            }
                            
                            TextField(
                                "(선택) 제목을 입력해주세요",
                                text: viewStore.binding(
                                    get: \.postTitle,
                                    send: { newValue in .view(.titleChanged(newValue)) }
                                )
                            )
                            .focused($isTextFieldFocused)
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(DesignSystemAsset.Colors.gray700.swiftUIColor)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                            
                            LimitedTextEditor(
                                text: viewStore.binding(
                                    get: \.postDescription,
                                    send: { newValue in .view(.descriptionChanged(newValue)) }
                                ),
                                placeholder: "어떤 생각을 하고 계신가요?\n학교 친구들과 함께 생각을 나눠보세요",
                                maxLength: 1200
                            )
                            .focused($isTextFieldFocused)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                            
                            HStack {
                                Spacer()
                                Text("\(viewStore.postDescription.count) / 1200")
                                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                    .padding(.trailing, 20)
                            }
                            
                            
                            VStack(alignment: .leading ,spacing: 4) {
                                Text("(선택) 사진 올리기")
                                    .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                                
                                Text("사진은 3장까지 올릴 수 있어요")
                                    .foregroundStyle(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                            }
                            .padding(.horizontal, 20)
                            
                            LazyHGrid(rows: [GridItem(.fixed(80))], spacing: 16) {
                                if viewStore.uiImages.count < 3 {
                                    PhotosPicker(
                                        selection: viewStore.binding(
                                            get: \.photoItems,
                                            send: { .view(.onPhotosChanged($0)) }
                                        ),
                                        maxSelectionCount: 3,
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ){
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(DesignSystemAsset.Colors.gray600.swiftUIColor)
                                                .frame(width: 90, height: 90)
                                            DesignSystemAsset.Images.icCommunityAddFiled.swiftUIImage
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
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
                                        
                                        // 선택 취소(X) 버튼
                                        Button {
                                            viewStore.send( .view(.onPhotosChanged(
                                                viewStore.photoItems.enumerated()
                                                    .filter { $0.offset != idx }
                                                    .map { $0.element }
                                            )))
                                        } label: {
                                            DesignSystemAsset.Images.icCommunityXmarkWhiteFiled.swiftUIImage
                                                .frame(width: 28, height: 28)
                                                .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                                                .background(Circle().fill(Color.gray.opacity(0.6)))
                                        }
                                        .offset(x: 10, y: -10)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .onChange(of: viewStore.photoItems) { newItems in
                                Task {
                                    var uiImages: [UIImage] = []
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            uiImages.append(uiImage)
                                        }
                                    }
                                    images = uiImages
                                }
                            }
                            
                            
                            Button(action: {
                                viewStore.send(.view(.submitButtonTapped))
                            }) {
                                Text("게시하기")
                                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                                    .foregroundColor(DesignSystemAsset.Colors.gray900.swiftUIColor) // 검은 글자
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: 52) // 높이 56 고정
                            .frame(maxWidth: .infinity) // 가로 꽉 채우기
                            .background(DesignSystemAsset.Colors.primary300.swiftUIColor) // 노란색 배경
                            .cornerRadius(12) // 모서리 둥글게
                            .padding(.top, 37)
                            .padding(.horizontal, 20) // 좌우 20 여백
                        }
                        
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                    .wsNavigationBar(
                        left:  { EmptyView() },
                        title: {
                            Text("게시글 작성")
                                .foregroundStyle(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        },
                        right: {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                DesignSystemAsset.Images.icCommunityXmarkFiled.swiftUIImage
                            }
                        }
                    )
                }
                .onChange(of: viewStore.didUploadSuccess) { didSuccess in
                    if didSuccess {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                }
                .onAppear {
                    NotificationCenter.default.post(name: .hideTabBar, object: nil)
                }
            }
            .transparentScrolling()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
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
