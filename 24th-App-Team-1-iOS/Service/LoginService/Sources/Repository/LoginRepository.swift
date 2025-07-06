//
//  LoginRepository.swift
//  LoginService
//
//  Created by eunseou on 7/30/24.
//

import Foundation
import Networking
import LoginDomain
import Util
import Extensions

import RxSwift
import RxCocoa

public final class LoginRepository: LoginRepositoryProtocol {
    
    private let networkService: WSNetworkServiceProtocol = WSNetworkService()
    
    public init() { }
    
    /// 로그인 하는 함수
    public func loginUser(body: LoginDomain.SignInUserRequest) -> Single<LoginDomain.LoginResultEnum?> {
        let body = SignInUserRequest(
            socialType: body.socialType,
            authorizationCode: body.authorizationCode,
            identityToken: body.identityToken,
            fcmToken: body.fcmToken
        )
        let endPoint = LoginEndPoint.executeSocialLogin(body)
        
        return networkService.requestWithStatusCode(endPoint: endPoint)
            .flatMap { (data, statusCode) -> Single<LoginDomain.LoginResultEnum?> in
                switch statusCode {
                case 200:
                    return Observable.just(data ?? Data())
                        .decodeMap(SignInUserRepsonseDTO.self)
                        .map { .success200($0.toDomain()) }
                        .asSingle()
                    
                case 202:

                    return Observable.just(data ?? Data())
                        .decodeMap(SignUpTokenResponseDTO.self)
                        .map { .success202($0.toDomain()) }
                        .asSingle()
                    
                default:
                    return Single.just(.unknown)
                }
            }
    }
    
    /// 유저정보 기입 및 가입
    public func SignUpUser(body: SignUpUserRequest) -> Single<SignUpTokenEntity?> {
        let consents = ConsentsRequestDTO(marketing: body.consents.marketing)
        let body = SignUPRequestDTO(name: body.name,
                                    gender: body.gender.uppercased(),
                                    schoolId: body.schoolId,
                                    grade: body.grade,
                                    classNumber: body.classNumber,
                                    consents: consents,
                                    signUpToken: body.signUpToken,
                                    profileUrl: body.profileUrl,
                                    introduction: body.introduction)
        let endPoint = LoginEndPoint.executeSingUp(body)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .decodeMap(CompleteSignUpResponseDTO.self)
            .logErrorIfDetected(category: Network.error)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchSchoolList(query: SchoolListRequestQuery) -> Single<SchoolListResponseEntity?> {
        let query = SchoolListRequestDTO(name: query.name, cursorId: query.cursorId)
        let endPoint = LoginEndPoint.fetchSchoolList(query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(SchoolListResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
}
