//
//  MyCategoryPostView.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/6/25.
//

import SwiftUI
import DesignSystem

import SwiftUI
import ComposableArchitecture

public enum MyCategoryType {
    case scrap
    case written
    case comment
    
    var title: String {
        switch self {
        case .scrap:
            return "스크랩 한 글"
        case .written:
            return "작성한 글"
        case .comment:
            return "댓글단 글"
        }
    }
}


struct MyCategoryPostView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    private func createStore(for category: MyCategoryType) -> StoreOf<MyPostCategoryFeature> {
        Store(
            initialState: MyPostCategoryFeature.State(category: category),
            reducer: { MyPostCategoryFeature() }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                NavigationLink(destination: MyPostCategoryView(store: createStore(for: .written))) {
                    MenuRowView(
                        icon: DesignSystemAsset.Images.icCommunityPencilGrayFiled.swiftUIImage,
                        title: "작성한 글"
                    )
                }
                
                NavigationLink(destination: MyPostCategoryView(store: createStore(for: .comment))) {
                    MenuRowView(
                        icon: DesignSystemAsset.Images.icCommunityCommentFiled.swiftUIImage,
                        title: "댓글 단 글"
                    )
                }
                
                NavigationLink(destination: MyPostCategoryView(store: createStore(for: .scrap))) {
                    MenuRowView(
                        icon: DesignSystemAsset.Images.icCommunityBookmarkFiled.swiftUIImage,
                        title: "스크랩한 글"
                    )
                }
            }
            
            Spacer()
        }
        .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    DesignSystemAsset.Images.arrow.swiftUIImage
                        .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                }
            }
        }
    }
}

struct MenuRowView: View {
    let icon: Image
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            icon
                .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                .frame(width: 20, height: 20)
            
            Text(title)
                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
            
            Spacer()
            
            DesignSystemAsset.Images.icProfileArrowFiled.swiftUIImage
                .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}
