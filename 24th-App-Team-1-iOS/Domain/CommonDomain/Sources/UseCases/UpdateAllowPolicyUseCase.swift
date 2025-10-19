//
//  UpdateAllowPolicyUseCase.swift
//  CommonDomain
//
//  Created by 김도현 on 10/14/25.
//


import Foundation

import RxSwift
import RxCocoa


public protocol UpdateAllowPolicyUseCaseProtocol {
    func execute(query: UpdateAllowPollcyQuery) -> Single<Bool>
}


public final class UpdateAllowPolicyUseCase: UpdateAllowPolicyUseCaseProtocol {
    
    public let commonRepository: CommonRepositoryProtocol
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    public func execute(query: UpdateAllowPollcyQuery) -> Single<Bool> {
        return commonRepository.updateAllowPollcyItems(query: query)
    }
}
