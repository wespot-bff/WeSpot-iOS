//
//  VoteRepository.swift
//  VoteService
//
//  Created by Kim dohyun on 7/22/24.
//

import Extensions
import Foundation
import Networking
import Util
import VoteDomain
import Storage

import RxSwift
import RxCocoa


public final class VoteRepository: VoteRepositoryProtocol {

    private let networkService: WSNetworkServiceProtocol = WSNetworkService()
    
    public init() { }
    
    public func fetchWinnerVoteOptions(query: VoteWinnerRequestQuery) -> Single<VoteWinnerResponseEntity?> {
        let query = VoteWinnerRequestDTO(date: query.date)
        let endPoint = VoteEndPoint.fetchWinnerVotes(query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(VoteWinnerResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
        
    }
    
    public func uploadFinalVoteResults(body: [CreateVoteItemReqeuest]) -> Single<CreateVoteEntity?> {
        let itemsBody = body.map { return CreateRequestItemsDTO(userId: $0.userId, voteOptionId: $0.voteOptionId) }
        let body = CreateVoteRequestDTO(votes: itemsBody)
        
        let endPoint = VoteEndPoint.addVotes(body)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .do { _ in WSCacheManager.shared.claer(for: WSCacheKey.voteOptions.rawValue) }
            .decodeMap(CreateVoteResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchAllVoteResults(query: VoteWinnerRequestQuery) -> Single<VoteAllReponseEntity?> {
        let query = VoteWinnerRequestDTO(date: query.date)
        let endPoint = VoteEndPoint.fetchResultVotes(query)

        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(VoteAllResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchVoteReceiveItems(query: VoteReceiveRequestQuery) -> Single<VoteRecevieEntity?> {
        let query = VoteReceiveRequestDTO(cursorId: query.cursorId)
        let endPoint = VoteEndPoint.fetchReceivedVotes(query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(VoteReceiveResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchVoteSentItems(query: VoteSentRequestQuery) -> Single<VoteSentEntity?> {
        let query = VoteSentRequestDTO(cursorId: query.cursorId)
        let endPoint = VoteEndPoint.fetchVoteSent(query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .decodeMap(VoteSentResponseDTO.self)
            .logErrorIfDetected(category: Network.error)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchVoteIndividualItem(id: Int, query: VoteIndividualQuery) -> Single<VoteIndividualEntity?> {
        let query = VoteIndividualRequestDTO(date: query.date)
        let endPoint = VoteEndPoint.fetchIndividualVotes(id, query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .decodeMap(VoteIndividualResponseDTO.self)
            .logErrorIfDetected(category: Network.error)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func createReportUserItem(body: CreateUserReportRequest) -> Single<CreateReportUserEntity?> {
        let body = CreateUserReportRequestDTO(reportType: body.type, targetId: body.targetId)
        let endPoint = VoteEndPoint.createUserReport(body)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .decodeMap(CreateReportUserResponseDTO.self)
            .logErrorIfDetected(category: Network.error)
            .map { $0.toDomain() }
            .asSingle()
    }
}
