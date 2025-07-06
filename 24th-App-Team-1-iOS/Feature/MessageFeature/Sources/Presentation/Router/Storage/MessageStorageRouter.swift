//
//  MessageStorageRouter.swift
//  MessageFeature
//roomInfo//  Created by 최지철 on 6/25/25.
//

import UIKit
import MessageDomain
import MessageService

public protocol MessageStorageRouting {
    func goToDetailMessage(room: MessageRoomDetailEntity, info: MessageRoomEntity, vc: UIViewController)
    
}
public final class MessageStorageRouter: MessageStorageRouting {
    
    public init() {}
    
    public func goToDetailMessage(room: MessageDomain.MessageRoomDetailEntity, info: MessageRoomEntity, vc: UIViewController) {
        let fetchSearchResultUseCase = FetchStudentSearchResultUseCaseImpl(repository: messageRepository())
        let writeMessageUseCase = WriteMessageUseCaseImpl(repository: messageRepository())
        let reactor = MessageWriteReactor(fetchSearchResultUseCase: fetchSearchResultUseCase,
                                          bottomSheetRouter: nil,
                                          anonmousProfileUseCase: nil,
                                          writeMessageUseCase: writeMessageUseCase)
        let detailMessageStorageViewController = DetailMessageStorageViewController(roomInfo: room, info: info)
        detailMessageStorageViewController.reactor = reactor
        vc.navigationController?.pushViewController(detailMessageStorageViewController, animated: true)
    }
}

