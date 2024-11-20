//
//  UpdateUserProfileUploadUseCase.swift
//  CommonDomain
//
//  Created by 김도현 on 11/14/24.
//

import Foundation

import RxSwift
import RxCocoa


public protocol UpdateUserProfileUploadUseCaseProtocol {
    func execute(_ image: Data, presigendURL: String) -> Single<Bool>
}


public final class UpdateUserProfileUploadUseCase: UpdateUserProfileUploadUseCaseProtocol {
    
    public let commonRepository: CommonRepositoryProtocol
    
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    public func execute(_ image: Data, presigendURL: String) -> Single<Bool> {
        return commonRepository.uploadUserProfileImage(image, presigendURL: presigendURL)
    }
}
