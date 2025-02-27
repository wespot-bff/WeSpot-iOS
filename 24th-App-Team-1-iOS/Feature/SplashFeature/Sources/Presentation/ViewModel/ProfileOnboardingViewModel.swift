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
        var imageComponent: ImageComponent?
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
            await handleProfileEditDeepLink(entity: currentState)
            return .none
        }
    }
    
    private func reduce(state: State, mutation: Mutation) async -> State {
        var newState = state
        switch mutation {
        case let .setComponentEntity(entity):
            newState.componentEntity = entity
            newState.titleComponentText = transformTitleComponentText(entity: entity)
            newState.topComponentText = transformTopComponentText(entity: entity)
            newState.subTitleComponentText = transformSubTitleComponentText(entity: entity)
            newState.imageComponent = transformImageComponent(entity: entity)
            newState.chipComponentText = transformChipComponent(entity: entity)
            newState.descriptionComponentText = transformDescriptionComponent(entity: entity)
            newState.descriptionImageComponent = transformDescriptionImageComponent(entity: entity)
            newState.leftButtonComponentText = transformLeftButtonComponent(entity: entity)
            newState.rightButtonComponentText = transformRightButtonComponent(entity: entity)
        case let .setComponentError(errorDescription):
            newState.errorDescription = errorDescription
        case .none:
            break
            
        }
        
        return newState
    }
    
    
}


extension ProfileOnboardingViewModel {
    private func transformTitleComponentText(entity: ProfileOnboardingEntity) -> String {
  
        guard let titleComponentType = entity.components.first(where: { $0.componentType == "titleComponent" }),
              let titleText = titleComponentType.titleText else { return "" }
        return titleText.replacingOccurrences(of: "사진으로 프", with: "사진으로\n프")
    }
    
    private func transformTopComponentText(entity: ProfileOnboardingEntity) -> String {
        guard let topComponentType = entity.components.first(where: { $0.componentType == "topBarComponent" }),
              let topText = topComponentType.titleText else { return "" }
        print("내비게이션 타이틀 확인 합니다 : \(topText)")
        return topText
    }
    
    private func transformSubTitleComponentText(entity: ProfileOnboardingEntity) -> String {
        guard let subtitleComponentType = entity.components.first(where: { $0.componentType == "subTitleComponent"}),
              let subTitletext = subtitleComponentType.titleText else { return "" }
        return subTitletext
    }
    
    private func transformImageComponent(entity: ProfileOnboardingEntity) -> ImageComponent? {
        guard let imageComponentType = entity.components.first(where: { $0.componentType == "imageComponent"}),
              let imageAbsoluteString = imageComponentType.imageURL,
              let imageURL = URL(string: imageAbsoluteString),
              let imageWidth = imageComponentType.width,
              let imageHeight = imageComponentType.height else { return nil }
        
        return (imageURL, imageWidth, imageHeight)
    }
    
    private func transformChipComponent(entity: ProfileOnboardingEntity) -> String {
        guard let chipComponent = entity.components.first(where: { $0.componentType == "chipComponent"}),
              let chipText = chipComponent.titleText else { return "" }
        return chipText
    }
    
    
    private func transformDescriptionComponent(entity: ProfileOnboardingEntity) -> String {
        guard let descriptionComponentType = entity.components.first(where: { $0.componentType == "descriptionComponent"}),
              let descriptionText = descriptionComponentType.titleText else { return "" }
        return descriptionText.replacingOccurrences(of: "프로필은 반", with: "프로필은\n반")
    }
    
    private func transformDescriptionImageComponent(entity: ProfileOnboardingEntity) -> ImageComponent? {
        guard let descriptionImageComponentType = entity.components.first(where: { $0.componentType == "descriptionImageComponent"}),
              let descriptionImageAbsoluteString = descriptionImageComponentType.imageURL,
              let descriptionImageURL = URL(string: descriptionImageAbsoluteString),
              let descriptionImageWidth = descriptionImageComponentType.width,
              let descriptionImageHeight = descriptionImageComponentType.height else { return nil }
        
        return (descriptionImageURL, descriptionImageWidth, descriptionImageHeight)
    }
    
    private func transformLeftButtonComponent(entity: ProfileOnboardingEntity) -> String {
        guard let buttonComponentType = entity.components.first(where: { $0.componentType == "buttonListComponent"}),
              let leftButton = buttonComponentType.buttonComponentList?.first else { return "" }
        
        return leftButton.text
    }
    
    private func transformRightButtonComponent(entity: ProfileOnboardingEntity) -> String {
        guard let buttonComponentType = entity.components.first(where: { $0.componentType == "buttonListComponent"}),
              let rightButton = buttonComponentType.buttonComponentList?.last else { return "" }
        
        return rightButton.text
    }
    
    @MainActor
    private func handleProfileEditDeepLink(entity: ProfileOnboardingEntity) async  {
        
        
        guard let buttonComponentType =  entity.components.first(where: { $0.componentType == "buttonListComponent"}),
              let rightButton = buttonComponentType.buttonComponentList?.last,
              let deepLink = rightButton.onClickAction.deepLink,
              let url = URL(string: deepLink),
              let urlScheme = url.scheme,
              let urlHost = url.host else { return }
        
        let urlPath = url.path
        
        print("딥링크 URL을 확인합니다 : \(url) , \(urlScheme) , \(urlHost) , \(urlPath)")
        
        if urlScheme == "wespot" && urlHost == "all" && urlPath == "/profile-edit" {
            NotificationCenter.default.post(name: .showProfileSettingViewController, object: nil)
        }

    }
    
}
