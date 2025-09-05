//
//  CategoryMainView.swift
//  CommunityFeature
//
//  Created by 김도현 on 9/5/25.
//



import SwiftUI
import ComposableArchitecture
import DesignSystem


@ViewAction(for: CategoryMainFeature.self)
struct CategoryMainView: View {
    var store: StoreOf<CategoryMainFeature>
    @StateObject private var viewStore: ViewStoreOf<CategoryMainFeature>
    @State private var showMainView: Bool = false
    
    public init(store: StoreOf<CategoryMainFeature>) {
        self.store = store
        self._viewStore = StateObject(
            wrappedValue: ViewStore(store, observe: \.self)
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    if let list = viewStore.postListEntity {
                        ForEach(list.items, id: \.id) { element in
                            if case .post(let post) = element,
                               let content = post.content {
                                PostView(content: content) {
                                    
                                } onTapLike: {
                                    
                                } onTapScrap: {
                                    
                                }
                                .padding(.horizontal, 20)
                            }
                            
                        }
                    }
                }
            }
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
            .wsNavigationBar(left: {
                Button {
                    showMainView = true
                } label: {
                    DesignSystemAsset.Images.icCommunityLeftArrowFiled.swiftUIImage
                }
            }, title: {
                Group {
                        HStack(spacing: 5) {
                            Button {
                                viewStore.send(.view(.didTappedCategoryButton))
                            } label: {
                                Text(viewStore.category.text)
                                    .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                
                                DesignSystemAsset.Images.icCommuntyCategoryChipFiled.swiftUIImage
                            }
                            
                            
                        }
                }
            }, right: {
                Button {
                    
                } label: {
                    DesignSystemAsset.Images.icCommunityDotFiled.swiftUIImage
                }
            })
            .onAppear {
                viewStore.send(.view(.onAppear))
            }
            .navigationBarBackButtonHidden(true)
            .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        }
    }
}
