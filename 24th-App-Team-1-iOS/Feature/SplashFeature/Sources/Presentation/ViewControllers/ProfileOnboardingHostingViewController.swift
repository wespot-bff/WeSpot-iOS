//
//  ProfileOnboardingHostingViewController.swift
//  SplashFeature
//
//  Created by 김도현 on 2/27/25.
//

import SwiftUI


public final class ProfileOnboardingHostingViewController: UIHostingController<ProfileOnboardingView> {
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
