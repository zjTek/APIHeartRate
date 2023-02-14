//
//  HRRepository.swift
//  APIHeartRate_Example
//
//  Created by Tek on 2023/1/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

protocol HRRepository {
    func startScan(timeOut: Double)
    func getConnectedDevice(uuid:[UUID]) -> [BleDicoveryDevice]
    func connectBluetooth(device: BleDicoveryDevice)
    func connectDeviceBy(deviceId: String)
    func disconnectDevice()
    func registerBleListener(listener: APIHeartRateObserver)
    func unregisterBleListener(listener: APIHeartRateObserver)
    func getDeviceBattery()
    func getDeviceManufacturer()
    func getDeviceModelNum()
    func getDeviceHardware()
    func getDeviceFirmware()
    func getDeviceSoftware()
    func getDeviceSystemID()
    func setDeviceThreshold(max: UInt8)
    func getDeviceSerial()
    func getDeviceStepFrequency()
    func getRealTimeOxygen()
    func getHearRate()
    func syncTime()
    func readCharValue(charUUID: String)
    func setCharNotify(charUUID: String, enabled: Bool)
    func writeChar(charUUID: String, data:Data)
}
