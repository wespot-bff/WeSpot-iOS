//
//  Adjusted+Extensions.swift
//  Extensions
//
//  Created by 김도현 on 11/11/24.
//

import UIKit

public extension Int {
    
    var adjusted: CGFloat {
      let ratio: CGFloat = UIScreen.main.bounds.width / 375
      let ratioH: CGFloat = UIScreen.main.bounds.height / 812
      return ratio <= ratioH ? CGFloat(self) * ratio : CGFloat(self) * ratioH
    }
    
    var adjustedWidth: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 375
        return CGFloat(self) * ratio
    }
    
    var adjustedHeight: CGFloat {
      let ratio: CGFloat = UIScreen.main.bounds.height / 812
      return CGFloat(self) * ratio
    }
    
    var adjustedSE: CGFloat {
      let ratio: CGFloat = UIScreen.main.bounds.width / 320
      let ratioH: CGFloat = UIScreen.main.bounds.height / 568
      return ratio <= ratioH ? CGFloat(self) * ratio : CGFloat(self) * ratioH
    }
    
    var adjustedWidthSE: CGFloat {
      let ratio: CGFloat = UIScreen.main.bounds.width / 320
      return CGFloat(self) * ratio
    }
    
    var adjustedHeightSE: CGFloat {
      let ratio: CGFloat = UIScreen.main.bounds.height / 568
      return CGFloat(self) * ratio
    }
}
