//
//  ReportView.swift
//  CommunityFeature
//
//  Created by 김도현 on 9/3/25.
//



import SwiftUI
import DesignSystem
import ComposableArchitecture
import CommunityDomain

struct ReportReasonView: View {
    @Perception.Bindable
    public var store: StoreOf<ReportFeature>
    @StateObject private var viewStore: ViewStore<ReportFeature.State, ReportFeature.Action>
    @FocusState private var isTextFieldFocused: Bool
    @State private var shouldNavigate = false
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<ReportFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }

    private var isEtcSelected: Bool {
        if let etcReason = viewStore.reportEntity.first(where: { $0.isEditable }) {
            return viewStore.selectedReasonIds.contains(etcReason.id)
        }
        return false
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                DesignSystemAsset.Colors.gray900.swiftUIColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    customNavigationBar

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            sectionTitle
                            sectionNotice
                            reportReasonsView()

                            if isTextFieldFocused {
                                Color.clear.frame(height: 300)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()

                    bottomConfirmButton
                }
            }
        }
        .onChange(of: viewStore.shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
        .onAppear {
            viewStore.send(.view(.onAppear))
        }
        .navigationBarHidden(true)
        .onTapGesture {
            if isTextFieldFocused {
                isTextFieldFocused = false
            }
        }
    }

    private var customNavigationBar: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                DesignSystemAsset.Images.arrow.swiftUIImage
            }
            Spacer()
            Text("신고")
                .foregroundStyle(DesignSystemAsset.Colors.gray100.swiftUIColor)
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
            Spacer()
            DesignSystemAsset.Images.arrow.swiftUIImage.opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }

    private var sectionTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("신고 사유를 선택해주세요")
                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 20))
        }
    }

    private var sectionNotice: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                DesignSystemAsset.Images.exclamationmarkFillDestructive.swiftUIImage
                    .frame(width: 24, height: 24)
                Text("유의사항")
                    .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
            }
            Text("허위 신고로 확인될 시 서비스 이용이 제한돼요")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                .padding(.top, 8)
            Text("*신고 누적 시 신고를 받은 유저의 이용이 제한돼요")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                .padding(.top, 16)
        }
    }

    @ViewBuilder
    private func reportReasonsView() -> some View {
        VStack(spacing: 12) {
            ForEach(viewStore.reportEntity.filter { !$0.isEditable }) { reason in
                let isSelected = viewStore.selectedReasonIds.contains(reason.id)
                
                Button {
                    viewStore.send(.view(.didTapReason(reason.id)))
                } label: {
                    HStack(spacing: 12) {
                        (isSelected ? DesignSystemAsset.Images.checkSelected.swiftUIImage : DesignSystemAsset.Images.check.swiftUIImage)
                            .frame(width: 26, height: 26)
                        
                        Text(reason.title)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        isSelected ? DesignSystemAsset.Colors.gray700.swiftUIColor : DesignSystemAsset.Colors.gray800.swiftUIColor
                    )
                    .cornerRadius(12)
                }
            }
            etcReasonInputView()
        }
    }

    @ViewBuilder
    private func etcReasonInputView() -> some View {
        if let etcReason = viewStore.reportEntity.first(where: { $0.isEditable }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if isEtcSelected {
                        TextEditor(
                            text: viewStore.binding(
                                get: \.etcText,
                                send: { .view(.updateEtcText($0)) }
                            )
                        )
                        .focused($isTextFieldFocused)
                        .frame(minHeight: 35)
                        .opacity(0.01)
                        .padding(EdgeInsets(top: 12, leading: 44, bottom: 12, trailing: 12))
                        
                        
                    }

                    HStack(spacing: 12) {
                        (isEtcSelected
                            ? DesignSystemAsset.Images.checkSelected.swiftUIImage
                            : DesignSystemAsset.Images.check.swiftUIImage
                        )
                        .frame(width: 26, height: 26)

                        Text(
                            viewStore.etcText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? "직접 입력"
                            : viewStore.etcText
                        )
                        .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .foregroundColor(
                            viewStore.etcText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isEtcSelected
                                ? DesignSystemAsset.Colors.gray400.swiftUIColor
                                : DesignSystemAsset.Colors.gray100.swiftUIColor
                        )
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)

                        Spacer()
                    }
                    .padding()
                    .background(
                        isEtcSelected
                        ? DesignSystemAsset.Colors.gray700.swiftUIColor
                        : DesignSystemAsset.Colors.gray800.swiftUIColor
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isTextFieldFocused
                                ? DesignSystemAsset.Colors.primary300.swiftUIColor
                                : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isEtcSelected {
                            viewStore.send(.view(.didTapReason(etcReason.id)))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isTextFieldFocused = true
                            }
                        } else {
                            isTextFieldFocused = true
                        }
                    }
                }

                if isEtcSelected {
                    HStack {
                        Spacer()
                        Text("\(viewStore.etcText.count)/100")
                            .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                            .padding(.top, 4)
                            .padding(.trailing, 12)
                    }
                }
            }
        }
    }

    private var bottomConfirmButton: some View {
        VStack(spacing: 0) {
            Button {
                viewStore.send(.view(.didTapSubmit))
            } label: {
                Text("선택 완료")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundColor(
                        viewStore.selectedReasonIds.isEmpty
                        ? DesignSystemAsset.Colors.gray300.swiftUIColor
                        : DesignSystemAsset.Colors.gray900.swiftUIColor
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        viewStore.selectedReasonIds.isEmpty
                        ? DesignSystemAsset.Colors.gray500.swiftUIColor
                        : DesignSystemAsset.Colors.primary300.swiftUIColor
                    )
                    .cornerRadius(12)
            }
            .disabled(viewStore.selectedReasonIds.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)

            if isTextFieldFocused {
                Color.clear.frame(height: 0)
            }
        }
        .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
    }
}
