//
//  APIHeartRateManager.swift
//  APIHeartRate
//
//  Created by Tek on 2023/1/6.
//

import Foundation

public class APIHeartRateManager {
    public static let instance = APIHeartRateManager()

    private var repo: APIHeartRateImp = APIHeartRateImp()

    /**
     添加监听
     每个添加的地方都会收到反馈值
     */
    public func addObserver(observer: APIHeartRateObserver) {
        repo.registerBleListener(listener: observer)
    }

    /**
     取消监听
     如果页面需要监听了，记得取消
     */
    public func removeObserver(observer: APIHeartRateObserver) {
        repo.unregisterBleListener(listener: observer)
    }

    /**
     开始扫描
     */
    public func startScan() {
        repo.startScan()
    }
    
    /**
     获取配对过的设备
     */
    public func getPairedDevices(uuid: [UUID]) -> [BleDicoveryDevice] {
        return repo.getConnectedDevice(uuid: uuid)
    }
    
    /**
     连接设备
     - parameter 蓝牙设备的deviceId
     */
    public func connectToDeviceByDeviceId(deviceId: String) {
        repo.connectDeviceBy(deviceId: deviceId)
    }
    /**
     连接设备
     - parameter 蓝牙设备对象
     */
    public func connectToDevice(device: BleDicoveryDevice) {
        repo.connectBluetooth(device: device)
    }

    /**
     获取Mac
     */
    public func getMac() {
        repo.getMacAddress()
    }

    /**
     获取设备电量,Int
     */
    public func readDeviceBatteryPower() {
        repo.getDeviceBattery()
    }

    /**
     获取厂商名称示例：LT
     */
    public func getManufacturerName() {
        repo.getDeviceManufacturer()
    }

    /**
     获取型号名称示例：2023-01-01
     */
    public func getModelName() {
        repo.getDeviceModelNum()
    }

    /**
     获取硬件版本示例：V3.1.0
     */
    public func getHardwareVersion() {
        repo.getDeviceHardware()
    }

    /**
     获取固件版本示例：V1.0
     */
    public func getFirmwareVersion() {
        repo.getDeviceFirmware()
    }

    /**
     获取软件版本示例：V2.8.4
     */
    public func getSoftwareVersion() {
        repo.getDeviceSoftware()
    }

    /**
     获取系统ID，16进制：0x05，0x04..
     */
    public func getSystemID() {
        repo.getDeviceSystemID()
    }

    /**
        请求断开连接
     */
    public func requestDisconnect() {
        repo.disconnectDevice()
    }

    /**
     设置震动阈值范围
     - parameter max:最大值
     */
    public func setHeartRateMax(heartRateMax: UInt8) {
        repo.setDeviceThreshold(max: heartRateMax)
    }

    /**
     获取设备序列号
     */
    public func getSerialNum() {
        repo.getDeviceSerial()
    }

    /**
     获取实时步频
     */
    public func getStepFrequency() {
        repo.getDeviceStepFrequency()
    }

    /**
     获取实时血氧
     */
    public func getRTOxygen() {
        repo.getRealTimeOxygen()
    }

    /**
     获取实时心率
     */
    public func getHeartRate() {
        repo.getHearRate()
    }
    /**
     同步系统时间
     */
    public func syncDeviceTime() {
        repo.syncTime()
    }
    /**
     读特征值
     */
    public func readCharacteristicValue(characteristicUuid: String){
        repo.readCharValue(charUUID: characteristicUuid)
    }
    /**
     设置特征监听
     */
    public func setCharacteristicNotification(characteristicUuid: String, enabled: Bool){
        repo.setCharNotify(charUUID: characteristicUuid, enabled: enabled)
    }
    /**
     写特征
     */
    public func writeToBle(characteristicUuid: String, cmd:Data){
        repo.writeChar(charUUID: characteristicUuid, data: cmd)
    }
}
