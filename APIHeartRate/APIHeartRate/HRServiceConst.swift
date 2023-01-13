//
//  ServiceContant.swift
//  APIHeartRate
//
//  Created by Tek on 2023/1/6.
//

import Foundation
import CoreBluetooth

struct HRServiceConst {
    // MARK: Properties
    static let batteryServiveID = CBUUID(string: "180F")
    static let batteryCharacteristic = CBUUID(string: "2A19")
    
    static let macServiveID = CBUUID(string: "FEE7")
    static let macCharacteristic = CBUUID(string: "FEC9")
    
    static let generalServiveID = CBUUID(string: "180A")
    static let manuCharacteristic = CBUUID(string: "2A29")
    static let modelCharacteristic = CBUUID(string: "2A24")
    static let hardwareCharacteristic = CBUUID(string: "2A27")
    static let firmwareCharacteristic = CBUUID(string: "2A26")
    static let softwareCharacteristic = CBUUID(string: "2A28")
    static let sysIDCharacteristic = CBUUID(string: "2A23")
    
    static let heartRateServiveID = CBUUID(string: "180D")
    static let heartNotifyCharacteristic = CBUUID(string: "2A37")
    static let heartReadCharacteristic = CBUUID(string: "2A38")
    
    static let customServiveID  = CBUUID(string: "66880000-0000-1000-8000-008012563489")
    static let writeCharacteristic  = CBUUID(string: "66880001-0000-1000-8000-008012563489")
    static let notifyCharacteristic  = CBUUID(string: "66880002-0000-1000-8000-008012563489")
    static let Characteristic = CBUUID(string: "2A19")
    static func characteristicUUIDsForServiceUUID(_ service: CBUUID) -> [CBUUID]{
        if (service == batteryServiveID) {
            return [batteryCharacteristic]
        } else if (service == generalServiveID) {
            return [manuCharacteristic, modelCharacteristic, hardwareCharacteristic, firmwareCharacteristic, softwareCharacteristic,sysIDCharacteristic]
        } else if (service == heartRateServiveID) {
            return [heartNotifyCharacteristic,heartReadCharacteristic]
        } else if (service == customServiveID) {
            return [notifyCharacteristic,writeCharacteristic]
        }
        return []
    }
}
