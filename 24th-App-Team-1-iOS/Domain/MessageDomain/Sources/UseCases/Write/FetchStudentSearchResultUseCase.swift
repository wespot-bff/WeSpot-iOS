//
//  FetchStudentSearchResultUseCase.swift
//  MessageDomain
//
//  Created by 최지철 on 12/26/24.
//

import Foundation

import RxSwift

public protocol FetchStudentSearchResultUseCase {
    func excute(query: SearchStudentRequest) -> Single<StudentListResponseEntity?>
}
public final class FetchStudentSearchResultUseCaseImpl: FetchStudentSearchResultUseCase {
    
    private let repository: MessageRepositoryProtocol
    
    public init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }
    
    public func excute(query: SearchStudentRequest) -> RxSwift.Single<StudentListResponseEntity?> {
        return repository.fetchStudentSearchResult(query: query)
    }
}

