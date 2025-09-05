//
//  UpdatePostAlarmUseCase.swift
//  AllDomain
//
//  Created by 김도현 on 9/5/25.
//

import Foundation

import RxSwift
import RxCocoa

public protocol UpdatePostAlarmUseCaseProtocol {
    
    func execute(body: UpdatePostAlarmRequest) -> Single<Bool>
}


public final class UpdatePostAlarmUseCase: UpdatePostAlarmUseCaseProtocol {
    
    private let profileRepository: ProfileRepositoryProtocol
    
    public init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    public func execute(body: UpdatePostAlarmRequest) -> Single<Bool> {
        return profileRepository.updatePostAlarmItems(body: body)
    }
    
}
