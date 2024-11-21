//
//  UpdateUserProfileImageUseCase.swift
//  AllDomain
//
//  Created by 김도현 on 11/12/24.
//

import Foundation

import RxSwift
import RxCocoa

public protocol UpdateUserProfileImageUseCaseProtocol {
    func execute(query: UpdateUserProfileImageRequestQuery) -> Single<UpdateUserProfileImageEntity?>
}

public final class UpdateUserProfileImageUseCase: UpdateUserProfileImageUseCaseProtocol {
    
    private let profileRepository: ProfileRepositoryProtocol
    
    public init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    public func execute(query: UpdateUserProfileImageRequestQuery) -> Single<UpdateUserProfileImageEntity?> {
        return profileRepository.updateUserProfileImage(query: query)
    }
}
