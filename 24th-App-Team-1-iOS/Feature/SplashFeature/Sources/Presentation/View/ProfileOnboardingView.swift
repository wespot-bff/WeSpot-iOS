//
//  ProfileOnboardingView.swift
//  SplashFeature
//
//  Created by 김도현 on 2/25/25.
//

import SwiftUI

import DesignSystem


public struct ProfileOnboardingView: View {
    @ObservedObject private var viewModel: ProfileOnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    public init(viewModel: ProfileOnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            WSNavigationBarView(navigationProperty: .leftWithCenterItem(DesignSystemAsset.Images.arrow.image, "새로운 기능"), text: viewModel.state.topComponentText)
                .frame(maxWidth: .infinity, minHeight: 60)
                .foregroundColor(DesignSystemAsset.Colors.gray900.swiftUIColor)
                .padding(.top, 44)

            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.state.titleComponentText)
                            .lineLimit(nil)
                            .lineSpacing(10)
                            .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 20))
                            .multilineTextAlignment(.leading)

                        Text(viewModel.state.subTitleComponentText)
                            .lineLimit(1)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .foregroundStyle(DesignSystemAsset.Colors.gray600.swiftUIColor)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, maxHeight: 21, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: viewModel.state.imageComponent?.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 270, maxHeight: 320)
                            case .failure(_):
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(UIColor(red: 27/255, green: 28/255, blue: 30/255, alpha: 0)), location: 0),
                                .init(color: Color(UIColor(red: 27/255, green: 28/255, blue: 30/255, alpha: 1)), location: 0.63),
                                .init(color: Color(UIColor(red: 27/255, green: 28/255, blue: 30/255, alpha: 1)), location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: 270, height: 116)
                        .clipped()
                    }
                    .frame(width: 270, height: 320)

                    VStack(alignment: .leading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(DesignSystemAsset.Colors.primary300.swiftUIColor, lineWidth: 1)
                                .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
                                .clipped()

                            Text(viewModel.state.chipComponentText)
                                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundStyle(DesignSystemAsset.Colors.white.swiftUIColor)
                        }
                        .frame(width: 113, height: 33)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 33, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    Text(viewModel.state.descriptionComponentText)
                        .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        .foregroundStyle(DesignSystemAsset.Colors.gray200.swiftUIColor)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, maxHeight: 42, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.bottom, 45)

                    ZStack(alignment: .bottom) {
                        AsyncImage(url: viewModel.state.descriptionImageComponent?.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: 270, maxHeight: 320)
                            case .failure(_):
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(UIColor(red: 27/255, green: 28/255, blue: 30/255, alpha: 0)), location: 0),
                                .init(color: Color(UIColor(red: 27/255, green: 28/255, blue: 30/255, alpha: 1)), location: 0.63),
                                .init(color: Color(UIColor(red: 27/255, green: 28/255, blue: 30/255, alpha: 1)), location: 1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: 270, height: 116)
                        .clipped()
                    }
                    .frame(width: 270, height: 320)

                }
                .padding(.top, 16)
            }
            .padding(.bottom, 40)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text(viewModel.state.leftButtonComponentText)
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(DesignSystemAsset.Colors.gray100.swiftUIColor)
                        .frame(width: 162, height: 52)
                        .background(DesignSystemAsset.Colors.gray500.swiftUIColor)
                        .cornerRadius(10)
                }

                Spacer()

                Button {
                    Task {
                        await viewModel.dispatcher(action: .didTappedUpdateProfile)
                    }
                } label: {
                    Text(viewModel.state.rightButtonComponentText)
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(DesignSystemAsset.Colors.gray900.swiftUIColor)
                        .frame(width: 162, height: 52)
                        .background(DesignSystemAsset.Colors.primary300.swiftUIColor)
                        .cornerRadius(10)
                }
            }
            .frame(width: 324, height: 52)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            Task {
                await viewModel.dispatcher(action: .viewDidLoad)
            }
        }
    }
    
    
    
    
}

#Preview {
    ProfileOnboardingView(viewModel: ProfileOnboardingViewModel())
}






public struct WSNavigationBarView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigationProperty: WSNavigationType
    @State private var text: String
    
    public init(navigationProperty: WSNavigationType, text: String) {
        self.navigationProperty = navigationProperty
        self.text = text
    }
    
    public var body: some View {
        makeContentView()
            .frame(maxWidth: .infinity, minHeight: 44)
    }
    
    @ViewBuilder
    private func makeContentView() -> some View {
        ZStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(uiImage: navigationProperty.items.leftItem ?? UIImage())
                        .padding(.leading, 20)
                }
                .padding(.leading, 20)
                .frame(width: 24, height: 24)
                
                Spacer()
                
                Text(navigationProperty.items.centerItem ?? "" )
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, maxHeight: 27)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        .foregroundColor(.white)
    }
}
