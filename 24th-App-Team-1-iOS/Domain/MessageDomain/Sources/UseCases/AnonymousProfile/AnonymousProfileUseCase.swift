//
//  AnonymousProfileUseCase.swift
//  MessageDomain
//
//  Created by 최지철 on 4/15/25.
//

import Foundation

import CommonDomain

public protocol AnonymousProfileUseCase {
    func getAnonymousProfileList(receiverId: Int) async throws -> [AnonymousProfileEntity]
    func uploadAnonymousProfileImage(imageData: Data) async throws -> String
}
public final class AnonymousProfileUseCaseImpl: AnonymousProfileUseCase {
    
    private let repository: MessageRepositoryProtocol
    private let imageUrlUsecase: CreatePresigendURLUseCaseProtocol
    private let updateUserProfileUploadUseCase :UpdateUserProfileUploadUseCaseProtocol?
    
    public init(repository: MessageRepositoryProtocol, imageUrlUsecase: CreatePresigendURLUseCaseProtocol, updateUserProfileUploadUseCase :UpdateUserProfileUploadUseCaseProtocol?) {
        self.repository = repository
        self.imageUrlUsecase = imageUrlUsecase
        self.updateUserProfileUploadUseCase = updateUserProfileUploadUseCase
    }
    
    public func getAnonymousProfileList(receiverId: Int) async throws -> [AnonymousProfileEntity] {
        let profileList = try await repository.fetchAnonymousProfileList(receiverId: 0)
        return profileList
    }
    
    public func uploadAnonymousProfileImage(imageData: Data) async throws -> String {
        let query = CreateProfilePresignedURLQuery(imageExtension: "jpeg")
        
        guard let urlResponse = try await imageUrlUsecase.execute(query: query).value else {
            throw URLError(.badServerResponse)
        }
        
        let presignedURL = urlResponse.presignedURL
        let finalImageURL = urlResponse.imageURL
        
        let result = updateUserProfileUploadUseCase?.execute(imageData, presigendURL: presignedURL)
        
        return finalImageURL
    }
}
