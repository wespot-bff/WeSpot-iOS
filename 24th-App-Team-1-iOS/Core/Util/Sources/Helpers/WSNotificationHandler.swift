//
//  WSNotificationHandler.swift
//  Util
//
//  Created by 김도현 on 12/8/24.
//

import Foundation

import Extensions
import UserNotifications

public final class WSNotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    
    public override init() {}
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let payload = NotificationPayload(dictionary: userInfo) else { return }
        let payloadType = payload.type
        //TODO: Coordinator Pattern으로 수정
        switch payloadType {
        case .voteMain:
            NotificationCenter.default.post(name: .showVoteMainViewController, object: nil)
        case .voteResult:
            NotificationCenter.default.post(name: .showVoteEffectViewController, object: nil)
        case .voteRecevied:
            NotificationCenter.default.post(name: .showVoteInventoryViewController, object: nil)
        case .profile:
            NotificationCenter.default.post(name: .showProfileOnboardingView, object: nil)
        default:
            break
        }
        
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}
