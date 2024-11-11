//
//  UIScreen+Extensions.swift
//  Extensions
//
//  Created by 김도현 on 11/11/24.
//

import UIKit


public extension UIScreen {
    var isWideScreen: Bool { self.bounds.size.width > 375 }
}
