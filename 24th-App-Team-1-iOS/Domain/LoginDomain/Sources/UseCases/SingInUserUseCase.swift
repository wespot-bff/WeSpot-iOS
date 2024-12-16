//
//  CreateSignUpTokenUseCase.swift
//  LoginDomain
//
//  Created by eunseou on 7/30/24.
//

import Foundation

import RxSwift
import RxCocoa

public protocol SignInUserUseCaseProtocol {
    func execute(body: SignInUserRequest) -> Single<LoginResultEnum?>
}

public final class SignInUserUseCase: SignInUserUseCaseProtocol {

    public let loginRepository: LoginRepositoryProtocol
    
    public init(loginRepository: LoginRepositoryProtocol) {
        self.loginRepository = loginRepository
    }

    public func execute(body: SignInUserRequest) -> Single<LoginResultEnum?> {
        return loginRepository.loginUser(body: body)
    }
    
}
