//
//  CreateReportUserUseCase.swift
//  VoteDomain
//
//  Created by 김도현 on 5/30/25.
//


import Foundation

import RxSwift
import RxCocoa

public protocol CreateReportUserUseCaseProtocol {
    func execute(body: CreateUserReportRequest) -> Single<CreateReportUserEntity?>
}

public final class CreateReportUserUseCase: CreateReportUserUseCaseProtocol {
    
    public let repository: VoteRepositoryProtocol
    
    public init(repository: VoteRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(body: CreateUserReportRequest) -> Single<CreateReportUserEntity?> {
        return repository.createReportUserItem(body: body)
    }
    
}
