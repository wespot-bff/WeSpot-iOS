//
//  LoginRepositoryProtocol.swift
//  LoginDomain
//
//  Created by eunseou on 7/30/24.
//

import Foundation

import RxSwift

public protocol LoginRepositoryProtocol {
    func LoginUser(body: LoginDomain.SignInUserRequest) -> Single<LoginDomain.LoginResultEnum?> // 로그인
    func SignUpUser(body: SignUpUserRequest) -> Single<SignUpTokenEntity?> //회원가입
    func fetchSchoolList(query: SchoolListRequestQuery) -> Single<SchoolListResponseEntity?> // 학교 검색
}
