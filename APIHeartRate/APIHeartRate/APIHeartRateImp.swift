//
//  APIHeartRateImp.swift
//  APIHeartRate_Example
//
//  Created by Tek on 2023/1/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import CoreBluetooth
import Foundation

class APIHeartRateImp: HRRemotePeripheralDelegate, HRRemotePeerDelegate, HRRepository, HRAvailabilityObserver, HRCentralDelegate {
    private var observers: [String: APIHeartRateObserver] = [:]
    private var central = HRCentral()
    private var remotePeripheral: BleDevice?
    private var logDisabled = false

    let cmdVibrate: UInt8 = 0x01
    let cmdSyncTime: UInt8 = 0x02
    let cmdSerial: UInt8 = 0x03
    let cmdStep: UInt8 = 0x04
    let cmdOxygen: UInt8 = 0x05

    init() {
        central.delegate = self
        central.addAvailabilityObserver(self)
        do {
            try central.startWithConfiguration()
        } catch {}
    }

    func disableLog(_ status: Bool) {
        logDisabled = status
    }

    func registerBleListener(listener: APIHeartRateObserver) {
        let clsName = String(describing: listener.self)
        observers[clsName] = listener
    }

    func unregisterBleListener(listener: APIHeartRateObserver) {
        let clsName = String(describing: listener.self)
        observers.removeValue(forKey: clsName)
    }

    func connectBluetooth(device: BleDicoveryDevice) {
        logStr(log: "开始连接")
        central.connect(remotePeripheral: device.remotePeripheral) { [weak self] peripheral, e in
            guard let err = e else {
                self?.logStr(log: "连接成功: \(device.macAddress)")
                self?.remotePeripheral = peripheral
                self?.remotePeripheral?.delegate = self
                self?.remotePeripheral?.peripheralDelegate = self
                return
            }
            self?.logStr(log: "连接失败\(err.localizedDescription)")
            self?.observers.forEach({ _, delegateApi in
                delegateApi.bleConnectError(error: err, device: device.remotePeripheral)
            })
        }
    }

    func startScan(timeOut: Double) {
        central.scanWithDuration(timeOut) { [weak self] newDiscoveries in
            self?.observers.forEach({ _, delegateApi in
                delegateApi.didDiscoveryWith(devices: newDiscoveries)
            })
        } completionHandler: { [weak self] result, scanError in
            self?.observers.forEach({ _, delegateApi in
                guard let res = result else {
                    let err = scanError ?? BleConnectError.scanFailed
                    delegateApi.bleConnectError(error: err, device: nil)
                    return
                }
                delegateApi.didFinishDiscoveryWith(devices: res) })
        }
    }
    
    func stopScan() {
        central.endScan()
    }

    func getConnectedDevice(uuid: [UUID]) -> [BleDicoveryDevice] {
        let ret = central.retrieveRemotePeripheralsWithUUIDs(remoteUUIDs: uuid)
        guard let remotes = ret else { return [] }
        var temp: [BleDicoveryDevice] = []
        for item in remotes {
            temp.append(BleDicoveryDevice(advertisementData: [:], remotePeripheral: item, RSSI: 90, macAddress: item.macAddress, name: item.name))
        }
        return temp
    }

    func connectDeviceBy(deviceId: String) {
        if let uuid = UUID(uuidString: deviceId), let remote = central.retrieveRemotePeripheralWithUUID(remoteUUID: uuid) {
            central.connect(remotePeripheral: remote) { [weak self] peripheral, errConnect in
                self?.handleConnectionResult(remote: peripheral, error: errConnect)
            }
        } else {
            autoConnectScan(deviceId: deviceId)
        }
    }

    internal func autoConnectScan(deviceId: String) {
        central.scanWithDuration { _ in
        } completionHandler: { [weak self] result, _ in
            guard let res = result, let device = res.filter({ $0.deviceId == deviceId }).first else {
                self?.observers.forEach({ _, delegateApi in
                    delegateApi.bleConnectError(error: .deviceNotFound, device: nil)
                })
                return
            }
            self?.central.connect(remotePeripheral: device.remotePeripheral) { remotePeripheral, errConnect in
                self?.handleConnectionResult(remote: remotePeripheral, error: errConnect)
            }
        }
    }

    internal func handleConnectionResult(remote: BleDevice, error: BleConnectError?) {
        guard let e = error else {
            remotePeripheral = remote
            remotePeripheral?.delegate = self
            remotePeripheral?.peripheralDelegate = self
            return
        }
        observers.forEach({ _, delegateApi in
            delegateApi.bleConnectError(error: e, device: nil) })
    }

    func disconnectDevice() {
        guard let remote = remotePeripheral else {
            observers.forEach({ _, delegateApi in
                delegateApi.bleConnectError(error: .deviceNotFound, device: nil) })
            return
        }
        observers.forEach({ _, delegateApi in
            delegateApi.bleConnectStatus(status: .disconnecting, device: remotePeripheral) })
        do {
            try central.disconnectRemotePeripheral(remote)
        } catch let e {
            observers.forEach({ _, delegateApi in
                delegateApi.bleConnectError(error: .failedToDisconnect(underlyingError: e), device: remote) })
        }
    }

    func getMacAddress() {
        readData(.mac)
    }

    func getDeviceBattery() {
        readData(.battery)
    }

    func getDeviceManufacturer() {
        readData(.manufacturer)
    }

    func getDeviceModelNum() {
        readData(.model)
    }

    func getDeviceHardware() {
        readData(.hardware)
    }

    func getDeviceFirmware() {
        readData(.firmware)
    }

    func getDeviceSoftware() {
        readData(.software)
    }

    func getDeviceSystemID() {
        readData(.sysid)
    }

    func getHearRate() {
        // readData(.rate)
    }

    func setDeviceThreshold(max: UInt8 = 0) {
        writeData(Data([cmdVibrate, max]))
    }

    func getDeviceSerial() {
        writeData(Data([cmdSerial]))
    }

    func getDeviceStepFrequency() {
        writeData(Data([cmdStep]))
    }

    func getRealTimeOxygen() {
        writeData(Data([cmdOxygen]))
    }

    func syncTime() {
        let cmp = Calendar.current.dateComponents(in: .current, from: Date())
        var year = cmp.year ?? 0
        if year > 2000 {
            year -= 2000
        }
        let mon = UInt8(cmp.month ?? 0)
        let day = UInt8(cmp.day ?? 0)
        let hour = UInt8(cmp.hour ?? 0)
        let min = UInt8(cmp.minute ?? 0)
        let second = UInt8(cmp.second ?? 0)
        writeData(Data([cmdSyncTime, UInt8(year), mon, day, hour, min, second]))
    }

    func readCharValue(charUUID: String) {
        guard let remote = remotePeripheral else {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.devieNotConnected) })
            return
        }
        let uid = CBUUID(string: charUUID)
        let result = central.readChar(uuid: uid, toRemotePeer: remote)
        if !result {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.serviceNotFound) })
        }
    }

    func setCharNotify(charUUID: String, enabled: Bool) {
        guard let remote = remotePeripheral else {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.devieNotConnected) })
            return
        }
        let uid = CBUUID(string: charUUID)
        let result = central.setCharNotify(uuid: uid, enable: enabled, toRemotePeer: remote)
        if !result {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.serviceNotFound) })
        }
    }

    func writeChar(charUUID: String, data: Data) {
        guard let remote = remotePeripheral else {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.devieNotConnected) })
            return
        }
        let uid = CBUUID(string: charUUID)
        let result = central.writeChar(uuid: uid, data, toRemotePeer: remote)
        if !result {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.serviceNotFound) })
        }
    }

    private func readData(_ type: BleDevice.ReadType) {
        guard let remote = remotePeripheral else {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.devieNotConnected) })
            return
        }
        let result = central.readData(type, toRemotePeer: remote)
        if !result {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.serviceNotFound) })
        }
    }

    private func writeData(_ data: Data) {
        guard let remote = remotePeripheral else {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.devieNotConnected) })
            return
        }
        let result = central.sendData(data, toRemotePeer: remote)
        if !result {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.serviceNotFound) })
        }
    }

    func checkCharacteristic(service: CBService, targetChar: CBUUID) -> CBCharacteristic? {
        if let chars = service.characteristics {
            for char in chars {
                if char.uuid.isEqual(targetChar) {
                    return char
                }
            }
        }
        return nil
    }

    func remotePeripheralIsReady(_ remotePeripheral: BleDevice) {
        observers.forEach({ _, delegateApi in
            delegateApi.bleConnectStatus(status: .connected, device: remotePeripheral) })
    }

    func remotePeripheral(_ remotePeripheral: BleDevice, didUpdateName name: String) {}

    func remotePeer(characteristic: CBCharacteristic, _ remotePeer: HRRemotePeer, didSendArbitraryData data: Data) {
        guard let cmdData = data.first, let remote = remotePeripheral else {
            observers.forEach({ _, delegateApi in
                delegateApi.bleCommonError(error: BleCommonError.receivedWrongData) })
            return
        }
        if characteristic.uuid == HRServiceConst.batteryCharacteristic {
            observers.forEach({ _, delegateApi in
                delegateApi.devicePower(power: String(cmdData), device: remote) })
        } else if characteristic.uuid == HRServiceConst.macCharacteristic {
            if data.count < 6 {
                observers.forEach({ _, delegateApi in
                    delegateApi.bleCommonError(error: BleCommonError.receivedWrongData) })
                return
            }
            let macStr = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", data[0], data[1], data[2], data[3], data[4], data[5])
            observers.forEach({ _, delegateApi in
                delegateApi.privateMacAddress(mac: macStr, device: remote) })
        } else if characteristic.uuid == HRServiceConst.manuCharacteristic {
            observers.forEach({ _, delegateApi in
                delegateApi.deviceManufacturerName(manufacturerName: String(data: data, encoding: .ascii) ?? "-", device: remote) })
        } else if characteristic.uuid == HRServiceConst.modelCharacteristic {
            observers.forEach({ _, delegateApi in
                delegateApi.deviceModelString(modelString: String(data: data, encoding: .utf8) ?? "-", device: remote) })
        } else if characteristic.uuid == HRServiceConst.hardwareCharacteristic {
            observers.forEach({ _, delegateApi in
                delegateApi.deviceHardware(version: String(data: data, encoding: .utf8) ?? "-", device: remote) })
        } else if characteristic.uuid == HRServiceConst.firmwareCharacteristic {
            observers.forEach({ _, delegateApi in
                delegateApi.deviceFirmware(version: String(data: data, encoding: .utf8) ?? "-", device: remote) })
        } else if characteristic.uuid == HRServiceConst.softwareCharacteristic {
            observers.forEach({ _, delegateApi in
                delegateApi.deviceSoftware(version: String(data: data, encoding: .utf8) ?? "", device: remote) })
        } else if characteristic.uuid == HRServiceConst.sysIDCharacteristic {
            observers.forEach({ _, delegateApi in
                delegateApi.deviceSystemData(systemData: data, device: remote) })
        } else if characteristic.uuid == HRServiceConst.heartNotifyCharacteristic {
            if data.count < 2 {
                observers.forEach({ _, delegateApi in
                    delegateApi.bleCommonError(error: BleCommonError.receivedWrongData) })
                return
            }
            observers.forEach({ _, delegateApi in
                delegateApi.armBandRealTimeHeartRate(hRInfo: HRInfo(rate: Int(data[1])), device: remote) })
        } else if characteristic.uuid == HRServiceConst.notifyCharacteristic {
            switch cmdData {
            case cmdVibrate:
                observers.forEach({ _, delegateApi in
                    delegateApi.armBandMaxHeartRateUpdated() })
                break
            case cmdSyncTime:
                observers.forEach({ _, delegateApi in
                    delegateApi.armBandSystemTimeUpdated() })
                break
            case cmdSerial:
                if data.count > 7 {
                    observers.forEach({ _, delegateApi in
                        delegateApi.deviceSerialNumber(serialNumer: String(data: data.dropFirst(1), encoding: .ascii) ?? "-", device: remote) })
                } else {
                    observers.forEach({ _, delegateApi in
                        delegateApi.bleCommonError(error: BleCommonError.receivedWrongData) })
                }
                break
            case cmdStep:
                if data.count > 2 {
                    observers.forEach({ _, delegateApi in
                        let v = Int(data[1] | (data[2] << 8))
                        delegateApi.armBandStepFrequency(frequencyDic: ["value": String(v)], device: remote) })
                } else {
                    observers.forEach({ _, delegateApi in
                        delegateApi.bleCommonError(error: BleCommonError.receivedWrongData) })
                }
                break
            case cmdOxygen:
                if data.count > 1 {
                    observers.forEach({ _, delegateApi in
                        delegateApi.armBandBloodOxygen(num: Int(data[1]), device: remote) })
                } else {
                    observers.forEach({ _, delegateApi in
                        delegateApi.bleCommonError(error: BleCommonError.receivedWrongData) })
                }
                break
            default:
                break
            }
        }
    }

    // MARK: Central Delegate

    func central(_ central: HRCentral, remotePeripheralDidDisconnect peripheral: BleDevice) {
        remotePeripheral = nil
        observers.forEach({ _, delegateApi in
            delegateApi.bleConnectStatus(status: .disconnected, device: remotePeripheral) })
    }

    func availabilityObserver(_ availabilityObservable: HRAvailabilityObservable, availabilityDidChange availability: BleAvailability) {
        observers.forEach({ _, delegateApi in
            delegateApi.bleAvailability(status: availability) })
    }

    func availabilityObserver(_ availabilityObservable: HRAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BleUnavailabilityCause) {
    }

    private func logStr(log: String) {
        if logDisabled {
            return
        }
        observers.forEach({ _, delegateApi in
            delegateApi.bleConnectLog(logString: "===== APIHearRate==== :" + log, device: remotePeripheral)
        })
    }
}
