//
//  SignUpUserUseCase.swift
//  LoginDomain
//
//  Updated by Choi    on 12/11/24
//  Created by eunseou on 7/30/24.
//

import Foundation

import RxSwift
import RxCocoa

public protocol SignUpUserUseCaseProtocol {
    func execute(body: SignUpUserRequest) -> Single<SignUpTokenEntity?>
}

public final class SignUpUserUseCase: SignUpUserUseCaseProtocol {

    public let loginRepository: LoginRepositoryProtocol
    
    public init(loginRepository: LoginRepositoryProtocol) {
        self.loginRepository = loginRepository
    }

    public func execute(body: SignUpUserRequest) -> Single<SignUpTokenEntity?> {
        return loginRepository.SignUpUser(body: body)
    }
}
