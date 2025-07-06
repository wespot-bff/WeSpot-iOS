//
//  AnonymousProfileReactor.swift
//  MessageFeature
//
//  Created by 최지철 on 4/13/25.
//

import MessageDomain
import Extensions
import Util
import DesignSystem
import CommonDomain

import ReactorKit
import RxSwift
import UIKit

public final class AnonymousProfileReactor: Reactor {
    
    // MARK: - UseCase
    
    private let usecase: AnonymousProfileUseCase
    public var router: AnonymousProfileBottomSheetRouting?

    // MARK: - Properties
    
    public var initialState: State
    
    public struct State {
        @Pulse var profileList: [AnonymousProfileEntity] = []
        @Pulse var isFull: Bool = false
        @Pulse var error: String = ""
        var userName: String = ""
        var profileImageURL: String = ""
        var profileImage: UIImage = DesignSystemAsset.Images.icBasicProfile.image
        var setProfileImageBottomSheet: [SetAnonymousProfileImageEnum] = [.setGalleryImage, .setBasicProfileImage]
        @Pulse var creationComplete: (name: String, imageUrl: String)?
    }
    
    public enum Action {
        case inputUserName(String)
        case presentMakeProfilePopup(vc: UIViewController, onProfileCreated: (String, String, Bool, UIImage) -> Void)
        case selectedProfile
        case fetchProfileList(id: Int)
        case setImageTapped(UIViewController)
        case setProfileImage(UIImage)
    }

    public enum Mutation {
        case setProfileList([AnonymousProfileEntity])
        case setError(String)
        case setImage(UIImage)
        case setUserName(String)
        case setProfileImageURL(String)
        case setProfileImage(UIImage)
        case setCreationComplete(name: String, imageUrl: String)
        

    }
    
    // MARK: - Init
    
    public init(usecase: AnonymousProfileUseCase,
                router: AnonymousProfileBottomSheetRouting?) {
        self.usecase = usecase
        self.router = router
        self.initialState = State()
        print("AnonymousProfileReactor initialized")
    }
}

    // MARK: - Reactor

extension AnonymousProfileReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
    
        case .presentMakeProfilePopup(let vc, let onProfileCreated):
            // Router를 호출하여 콜백을 그대로 전달한다.
            router?.popUpmakeAnonyProfile(vc: vc, onProfileCreated: onProfileCreated)
            return .empty()
        case .selectedProfile:
            return Observable.empty()

        case .fetchProfileList(let id):
            return getProfileList(id: id)
        case .setImageTapped(let vc):
            router?.presenSetImagetBottomSheet(vc: vc)
            return Observable.empty()
        case .setProfileImage(let profileImage):
            let updateUIImage = Observable.just(Mutation.setImage(profileImage))

            guard let imageData = profileImage.jpegData(compressionQuality: 0.5) else {
                return .empty()
            }


            let uploadImage = Observable<Mutation>.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                Task {
                    do {
                        let resultURL = try await self.usecase.uploadAnonymousProfileImage(imageData: imageData)
                        observer.onNext(Mutation.setProfileImageURL(resultURL))
                    } catch {
                        observer.onNext(Mutation.setError(error.localizedDescription))
                    }
                    observer.onCompleted()
                }
                return Disposables.create()
            }

            return .concat([updateUIImage, uploadImage])
        
                
        case .inputUserName(let text):
            return Observable.just(Mutation.setUserName(text))
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setProfileList(let list):
            print("AnonymousProfileList: \(list)")
            newState.profileList = list
        case .setError(let error):
            newState.error = error
        case .setImage(let image):
            newState.profileImage = image
        case .setUserName(let name):
            newState.userName = name
        case .setProfileImageURL(let url):
            print("Profile Image URL: \(url)")
            newState.profileImageURL = url
        case .setCreationComplete(name: let name, imageUrl: let imageUrl):
            newState.creationComplete = (name, imageUrl)
        case .setProfileImage(let image):
            newState.profileImage = image
        }
        return newState
    }
}


    // MARK: - Mutation Logic

extension AnonymousProfileReactor {
    private func getProfileList(id: Int) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            Task {
                do {
                    let entity = try await self.usecase.getAnonymousProfileList(receiverId: id)
                    observer.onNext(Mutation.setProfileList(entity))
                } catch {
                    observer.onNext(Mutation.setError(error.localizedDescription))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

 
