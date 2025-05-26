//
//  ProfileOnboardingViewModel.swift
//  SplashFeature
//
//  Created by 김도현 on 2/25/25.
//

import Foundation

import Util
import CommonDomain
import SplashDomain

typealias ImageComponent = (imageURL:URL, imageWidth: Int, imageHeight: Int)

public final class ProfileOnboardingViewModel: ObservableObject {
    
    
    @Published var state: State = .init()
    @Injected private var fetchProfileOnboardingUseCase: FetchProfileOnboardingInfoUseCaseProtocol
    
    struct State {
        var componentEntity: ProfileOnboardingEntity?
        var titleComponentText: String = ""
        var topComponentText: String = ""
        var subTitleComponentText: String = ""
        var errorDescription: String = ""
        var imageComponent: URL?
        var descriptionComponentText: String = ""
        var chipComponentText: String = ""
        var descriptionImageComponent: ImageComponent?
        var leftButtonComponentText: String = ""
        var rightButtonComponentText: String = ""
        
    }
    
    public enum Action {
        case viewDidLoad
        case didTappedUpdateProfile
    }
    
    
    public enum Mutation {
        case setComponentEntity(ProfileOnboardingEntity)
        case setComponentError(String)
        case none
    }
    
    public init() { }
    
    public func dispatcher(action: Action) async {
        let mutation = await mutate(action)
        let newState = await reduce(state: state, mutation: mutation)
        await MainActor.run {
            state = newState
        }
    }
    
    private func mutate(_ action: Action) async -> Mutation {
        switch action {
        case .viewDidLoad:
            let query = ProfileOnboardingQuery(publishNotificationType: "PROFILE_UPDATE")
            do {
                let response = try await fetchProfileOnboardingUseCase.execute(query: query)
                return .setComponentEntity(response)
            } catch {
                return .setComponentError(error.localizedDescription)
            }
        case .didTappedUpdateProfile:
            guard let currentState = state.componentEntity else { return .none }
//            await handleProfileEditDeepLink(entity: currentState)
            return .none
        }
    }
    
    private func reduce(state: State, mutation: Mutation) async -> State {
        var newState = state
        switch mutation {
        case let .setComponentEntity(entity):
            newState.componentEntity = entity
            newState.titleComponentText = transformTitle(entity: entity)
            newState.topComponentText = transformTopBarTitle(entity: entity)
            newState.subTitleComponentText = transformSubtitle(entity: entity)
            newState.imageComponent = transformImageComponent(entity: entity)
//            newState.chipComponentText = transformChipComponent(entity: entity)
//            newState.descriptionComponentText = transformDescriptionComponent(entity: entity)
//            newState.descriptionImageComponent = transformDescriptionImageComponent(entity: entity)
            newState.leftButtonComponentText = transformSkipTextComponent(entity: entity)
//            newState.rightButtonComponentText = transformRightButtonComponent(entity: entity)
            print("프로필 온보딩 컴포넌트 데이터를 확인 합니다 \(newState.componentEntity)")
            print("프로필 온보딩 타이틀 데이터를 확인 합니다 \(newState.componentEntity)")
            print("프로필 온보딩 탑 컵포넌트 확인 합니다 \(newState.componentEntity)")
            print("프로필 온보딩 서브 타이틀 데이터를 확인 합니다 \(newState.componentEntity)")
            print("프로필 온보딩 이미지 컴포넌트 데이터를 확인 합니다 \(newState.componentEntity)")
            
            
            
        case let .setComponentError(errorDescription):
            newState.errorDescription = errorDescription
        case .none:
            break
            
        }
        
        return newState
    }
    
    
}

extension ProfileOnboardingViewModel {
    func transformTitle(entity: ProfileOnboardingEntity) -> String {
        guard
            let comp = entity.component(in: "contentSection", ofType: "textComponent")
        else { return "" }
        return comp.content.richText?.text.replacingOccurrences(of: "\\n", with: "\n") ?? ""
    }

    func transformTopBarTitle(entity: ProfileOnboardingEntity) -> String {
        guard
            let comp = entity.component(in: "contentSection", ofType: "topBarComponent")
        else { return "" }
        return comp.content.richText?.text ?? ""
    }

    func transformTopBarIconURL(entity: ProfileOnboardingEntity) -> URL? {
        guard
            let comp = entity.component(in: "contentSection", ofType: "topBarComponent"),
            let urlString = comp.content.icons?.first?.url
        else { return nil }
        return URL(string: urlString)
    }
    
    func transformImageComponent(entity: ProfileOnboardingEntity) -> URL? {
        guard
            let comp      = entity.component(in: "contentSection", ofType: "imageComponent"),
            let urlString = comp.content.url,
            let url       = URL(string: urlString)
        else { return nil }
        print("💚이미지 데이터를 확인합니다잉 \(urlString)💚")
        return url
    }

    func transformSubtitle(entity: ProfileOnboardingEntity) -> String {
        guard
            let section = entity.data.first(where: { $0.type == "contentSection" })
        else { return "" }

        let textComps = section.components.filter { $0.componentType == "textComponent" }
        if textComps.count > 1 {
            return textComps[1].content.richText?.text ?? ""
        }
        return ""
    }
    
    func transformChipText(entity: ProfileOnboardingEntity) -> String {
        guard
            let comp = entity.component(in: "contentSection", ofType: "chipComponent")
        else { return "" }
        return comp.content.richText?.text ?? ""
    }
    
    func transformBackgroundImage(entity: ProfileOnboardingEntity) -> ImageComponent? {
        guard let comp = entity.component(in: "contentSection", ofType: "imageComponent") else { return nil }
        
        return nil
    }

    func transformSkipTextComponent(entity: ProfileOnboardingEntity) -> String {
        guard let comp = entity.component(in: "bottomSection", ofType: "buttonsComponent") else { return "" }
        let richText = comp.content.buttons?.first?.richText.text ?? ""
        
        print("💙 바텀 버튼 텍스트 값 확인 \(richText) 💙")
        return richText
    }
    
    func transformProfileEditComponent(entity: ProfileOnboardingEntity) -> String {
        guard let comp = entity.component(in: "bottomSection", ofType: "buttonsComponent") else { return "" }
        let richText = comp.content.buttons?.last?.richText.text ?? ""
        
        print("❣️바텀 마지막 버튼 텍스트 값 확인 \(richText) ❣️")
        return richText
    }
    
    func transformDeepLinkURL(entity: ProfileOnboardingEntity) -> URL? {
        return nil
    }
}


