//
//  NoticeSearchView.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/22/25.
//

import SwiftUI
import DesignSystem



struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        HStack {
            DesignSystemAsset.Images.icCommunitySesarchFiled.swiftUIImage
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .frame(maxWidth:  .infinity, maxHeight: 56)
    }
}

public struct NoticeSearchView: View {
    @State private var searchText = ""
    @Environment(\.presentationMode) private var presentationMode
    public var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header:
                        SearchBar(text: $searchText,
                                  placeholder: "글 제목, 내용을 검색해 주세요")
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .background(DesignSystemAsset.Colors.gray800.swiftUIColor)
                    ) {

                    }
                }
                .onAppear {
                    NotificationCenter.default.post(name: .hideTabBar, object: nil)
                }
            }
            .background(DesignSystemAsset.Colors.gray800.swiftUIColor)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        DesignSystemAsset.Images.arrow.swiftUIImage
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.bottom)
    }
}

