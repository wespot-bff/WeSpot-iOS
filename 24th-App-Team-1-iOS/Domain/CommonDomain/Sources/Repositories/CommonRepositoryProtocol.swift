//
//  CommonRepositoryProtocol.swift
//  CommonDomain
//
//  Created by eunseou on 8/4/24.
//

import Foundation

import RxSwift

public protocol CommonRepositoryProtocol {
    func createCheckProfanity(body: CreateCheckProfanityRequest) -> Single<Bool>
    func fetchProfileImages() -> Single<FetchProfileImageResponseEntity?>
    func updateUserProfileItem(body: UpdateUserProfileRequest) -> Single<Bool>
    func fetchProfileBackgrounds() -> Single<FetchProfileBackgroundsResponseEntity?>
    func createReportUserItem(body: CreateUserReportRequest) -> Single<CreateReportUserEntity?>
}
