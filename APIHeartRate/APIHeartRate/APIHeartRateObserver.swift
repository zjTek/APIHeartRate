//
//  APIHeatRateDelegateProxy.swift
//  APIHeartRate_Example
//
//  Created by Tek on 2023/1/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
public enum DeviceBleStatus {
    case connecting
    case connected
    case disconnected
}

public struct FBKApiBaseInfo {}
public struct HRInfo {
    public let time: String
    public let rateStr: String
    init(rate: Int) {
        time = HRInfo.getTimeStr()
        rateStr = String(rate)
    }
    internal static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        return formatter
    }()
    static func getTimeStr()-> String{
        let stringWithDate = dateFormatter.string(from: Date())
        return stringWithDate
    }
}
public protocol APIHeartRateObserver {
    func devicePower(power: String, device: BleDevice)
    func deviceFirmware(version: String, device: BleDevice)
    func deviceHardware(version: String, device: BleDevice)
    func deviceSoftware(version: String, device: BleDevice)
    func privateVersion(version: [String:String], device: BleDevice)
    func privateMacAddress(mac: String, device: BleDevice)
    func deviceSystemData(systemData: Data, device: BleDevice)
    func deviceModelString(modelString: String, device: BleDevice)
    func deviceSerialNumber(serialNumer: String, device: BleDevice)
    func deviceManufacturerName(manufacturerName: String, device: BleDevice)
    func deviceBaseInfo(baseInfo: FBKApiBaseInfo, device: BleDevice)
    func HRVResultData(hrvMap: [String:String], device: BleDevice)
    func armBandStepFrequency(frequencyDic: [String:String], device: BleDevice)
    func armBandTemperature(tempMap: [String:String], device: BleDevice)
    func armBandSPO2(spo2Map: [String:String], device: BleDevice)
    func armBandRealTimeHeartRate(hRInfo: HRInfo, device: BleDevice)
    func armBandMaxHeartRateUpdated()
    func armBandSystemTimeUpdated()
    func armBandBloodOxygen(num: Int, device: BleDevice)
    
    func bleConnectLog(logString: String, device:BleDevice?)
    func bleConnectStatus(status: DeviceBleStatus, device: BleDevice?)
    func bleConnectError(error: BleConnectError, device: BleDevice?)
    func didDiscoveryWith(discovery: [BleDicoveryDevice])
    func didFinishDiscoveryWith(discovery: [BleDicoveryDevice])
    func bleCommonError(error: BleCommonError)
    func bleAvailability(status: BleAvailability)
}

extension APIHeartRateObserver {
    func devicePower(power: String, device: BleDevice) {}
    func deviceFirmware(version: String, device: BleDevice) {}
    func deviceHardware(version: String, device: BleDevice) {}
    func deviceSoftware(version: String, device: BleDevice) {}
    func privateVersion(version: [String: String], device: BleDevice) {}
    func privateMacAddress(mac: String, device: BleDevice) {}
    func deviceSystemData(systemData: Data, device: BleDevice) {}
    func deviceModelString(modelString: String, device: BleDevice) {}
    func deviceSerialNumber(serialNumer: String, device: BleDevice) {}
    func deviceManufacturerName(manufacturerName: String, device: BleDevice) {}
    func deviceBaseInfo(baseInfo: FBKApiBaseInfo, device: BleDevice) {}
    func HRVResultData(hrvMap: [String: String], device: BleDevice) {}
    func armBandStepFrequency(frequencyDic: [String: String], device: BleDevice) {}
    func armBandTemperature(tempMap: [String: String], device: BleDevice) {}
    func armBandSPO2(spo2Map: [String: String], device: BleDevice) {}
    func armBandRealTimeHeartRate(hRInfo: HRInfo, device: BleDevice) {}
    func armBandMaxHeartRateUpdated() {}
    func armBandSystemTimeUpdated() {}
    func armBandBloodOxygen(num: Int, device: BleDevice) {}

    func bleConnectLog(logString: String, device: BleDevice?) {}
    func bleConnectStatus(status: DeviceBleStatus, device: BleDevice?) {}
    func bleConnectError(error: BleConnectError, device: BleDevice?) {}
    func didDiscoveryWith(discovery: [BleDicoveryDevice]) {}
    func didFinishDiscoveryWith(discovery: [BleDicoveryDevice]) {}
    func bleCommonError(error: BleCommonError) {}
    func bleAvailability(status: BleAvailability) {}
}
