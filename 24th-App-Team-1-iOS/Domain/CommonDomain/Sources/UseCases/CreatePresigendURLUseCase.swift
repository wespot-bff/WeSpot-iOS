//
//  CreatePresigendURLUseCase.swift
//  CommonDomain
//
//  Created by 김도현 on 11/12/24.
//

import Foundation

import RxSwift
import RxCocoa

public protocol CreatePresigendURLUseCaseProtocol {
    func execute(query: CreateProfilePresignedURLQuery) -> Single<CreateProfilePresignedURLEntity?>
}

public final class CreatePresigendURLUseCase: CreatePresigendURLUseCaseProtocol {
    private let commonRepository: CommonRepositoryProtocol
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    public func execute(query: CreateProfilePresignedURLQuery) -> Single<CreateProfilePresignedURLEntity?> {
        return commonRepository.createProfilePresignedURL(query: query)
    }
}
