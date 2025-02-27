//
//  CommonRepositoryProtocol.swift
//  CommonDomain
//
//  Created by eunseou on 8/4/24.
//

import Foundation

import RxSwift

public protocol CommonRepositoryProtocol {
    func fetchUserProfileItems() -> Single<UserProfileEntity?>
    func createCheckProfanity(body: CreateCheckProfanityRequest) -> Single<Bool>
    func updateUserProfileItem(body: UpdateUserProfileRequest) -> Single<Bool>
    func createReportUserItem(body: CreateUserReportRequest) -> Single<CreateReportUserEntity?>
    func fetchVoteOptions() -> Single<VoteResponseEntity?>
    func createProfilePresignedURL(query: CreateProfilePresignedURLQuery) -> Single<CreateProfilePresignedURLEntity?>
    func uploadUserProfileImage(_ image: Data, presigendURL: String) -> Single<Bool>
    func fetchAppVersionItem() async throws -> WSVersionEntity
    func fetchProfileOnbardingItem(query: ProfileOnboardingQuery) async throws -> ProfileOnboardingEntity
}
