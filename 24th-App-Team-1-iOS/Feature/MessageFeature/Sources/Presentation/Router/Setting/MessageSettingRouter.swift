//
//  MessageSettingRouter.swift
//  MessageFeature
//
//  Created by 최지철 on 5/31/25.
//

import UIKit

import AllDomain
import AllService
import MessageDomain
import MessageService
import NotificationService

public protocol MessageSettingRouting {
    func goToSetting(_ list: MessageDomain.MessageSettingListEnum, _ vc: UIViewController)
}
public class MessageSettingRouter: MessageSettingRouting {
    public func goToSetting(_ list: MessageDomain.MessageSettingListEnum, _ vc: UIViewController) {
        let usecase = MessageSettingUsecaseImpl(repository: messageRepository())
        let notiUsecase = FetchUserAlarmSettingUseCase(profileRepository: ProfileRepository())
        let uploadUsecase = UpdateUserAlarmSettingUseCase(profileRepository: ProfileRepository())
        let reactor = MessageSettingReactor(usecase: usecase,
                                            router: self,
                                            notiUsecase: notiUsecase, uploadNotiUsecase: uploadUsecase)
        switch list {
        case .blockList:
            let blockListVC = BlockMessageListViewContoller(reactor: reactor)
            vc.navigationController?.pushViewController(blockListVC, animated: true)
        case .incomingOutgoing, .alert:
            let alertVC = SetMessageAlertViewController(viewType: list, reactor: reactor)
            vc.navigationController?.pushViewController(alertVC, animated: true)
        }
    }
    public init() {
        
    }
}
