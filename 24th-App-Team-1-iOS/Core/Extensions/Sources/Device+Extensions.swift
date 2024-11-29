//
//  Device+Extensions.swift
//  Extensions
//
//  Created by 김도현 on 11/19/24.
//

import Foundation

public enum Device: Equatable {
    case iPhone4
    case iPhone4s
    case iPhone5
    case iPhone5c
    case iPhone5s
    case iPhone6
    case iPhone6Plus
    case iPhone6s
    case iPhone6sPlus
    case iPhone7
    case iPhone7Plus
    case iPhoneSE
    case iPhone8
    case iPhone8Plus
    case iPhoneX
    case iPhoneXR
    case iPhoneXS
    case iPhoneXSMax
    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax
    case iPhoneSE2
    case iPhone12
    case iPhone12Mini
    case iPhone12Pro
    case iPhone12ProMax
    case iPhone13
    case iPhone13Mini
    case iPhone13Pro
    case iPhone13ProMax
    case iPhoneSE3
    case iPhone14
    case iPhone14Plus
    case iPhone14Pro
    case iPhone14ProMax
    case iPhone15
    case iPhone15Plus
    case iPhone15Pro
    case iPhone15ProMax
    case iPhone16
    case iPhone16Plus
    case iPhone16Pro
    case iPhone16ProMax
    case unknown(String)
}

extension Device {
    
    public static var current: Device {
      return Device.mapToDevice(identifier: Device.identifier)
    }
    
    public static var identifier: String = {
   #if targetEnvironment(simulator)
       if let simulatorIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
         return simulatorIdentifier
       }
   #endif

       var systemInfo = utsname()
       uname(&systemInfo)
       let mirror = Mirror(reflecting: systemInfo.machine)
       
       let identifier = mirror.children.reduce("") { identifier, element in
         guard let value = element.value as? Int8, value != 0 else { return identifier }
         return identifier + String(UnicodeScalar(UInt8(value)))
       }
       return identifier
     }()
    
    public static func mapToDevice(identifier: String) -> Device {
      switch identifier {
      case "iPhone3,1", "iPhone3,2", "iPhone3,3": return iPhone4
      case "iPhone4,1": return iPhone4s
      case "iPhone5,1", "iPhone5,2": return iPhone5
      case "iPhone5,3", "iPhone5,4": return iPhone5c
      case "iPhone6,1", "iPhone6,2": return iPhone5s
      case "iPhone7,2": return iPhone6
      case "iPhone7,1": return iPhone6Plus
      case "iPhone8,1": return iPhone6s
      case "iPhone8,2": return iPhone6sPlus
      case "iPhone9,1", "iPhone9,3": return iPhone7
      case "iPhone9,2", "iPhone9,4": return iPhone7Plus
      case "iPhone8,4": return iPhoneSE
      case "iPhone10,1", "iPhone10,4": return iPhone8
      case "iPhone10,2", "iPhone10,5": return iPhone8Plus
      case "iPhone10,3", "iPhone10,6": return iPhoneX
      case "iPhone11,2": return iPhoneXS
      case "iPhone11,4", "iPhone11,6": return iPhoneXSMax
      case "iPhone11,8": return iPhoneXR
      case "iPhone12,1": return iPhone11
      case "iPhone12,3": return iPhone11Pro
      case "iPhone12,5": return iPhone11ProMax
      case "iPhone12,8": return iPhoneSE2
      case "iPhone13,2": return iPhone12
      case "iPhone13,1": return iPhone12Mini
      case "iPhone13,3": return iPhone12Pro
      case "iPhone13,4": return iPhone12ProMax
      case "iPhone14,5": return iPhone13
      case "iPhone14,4": return iPhone13Mini
      case "iPhone14,2": return iPhone13Pro
      case "iPhone14,3": return iPhone13ProMax
      case "iPhone14,6": return iPhoneSE3
      case "iPhone14,7": return iPhone14
      case "iPhone14,8": return iPhone14Plus
      case "iPhone15,2": return iPhone14Pro
      case "iPhone15,3": return iPhone14ProMax
      case "iPhone15,4": return iPhone15
      case "iPhone15,5": return iPhone15Plus
      case "iPhone16,1": return iPhone15Pro
      case "iPhone16,2": return iPhone15ProMax
      default: return unknown(identifier)
      }
    }
    
    public static var allTouchIDCapableDevices: [Device] {
      return [.iPhone5s, .iPhone6, .iPhone6Plus, .iPhone6s, .iPhone6sPlus, .iPhone7, .iPhone7Plus, .iPhoneSE, .iPhone8, .iPhone8Plus, .iPhoneSE2, .iPhoneSE3]
    }
    
    public static var isTouchIDCapableDevice: Bool {
        let device = Device.current
        return Device.allTouchIDCapableDevices.contains(device)
    }
}
