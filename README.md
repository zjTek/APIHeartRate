# APIHeartRate
sdk for heartrate band

[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/APIHeartRate.svg)](https://img.shields.io/cocoapods/v/APIHeartRate.svg)

## Requirements
- iOS 10.0+
- Xcode 10.0+

## 安装

#### CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

如果你没有cocoapods
```bash
$ gem install cocoapods
```

在 `Podfile`中添加:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

pod 'APIHeartRate'
```

接着运行:

```bash
$ pod install
```


#### 手动安装

下载源文件APIHearateAPIV2.zip
解压后得到xcframework文件，放入自己的项目



## 用法



#### 引入头文件
在项目中引入
```swift
import APIHearateAPI
```

#### APIHeartRateManager
APIHeartRateManager是一个单例类，所有的连接和数据监听操作都通过它来实现

持有一个引用
```swift
let apiManager = APIHeartRateManager.instance
```
注册监听
```swift
apiManager.addObserver(observer: self)
```
方法调用
```swift
//扫描设备    
apiManager.startScan()
//获取电量
apiManager.getBatteryPower()
//获取厂商名
apiManager.getManufacturerName()
//获取Model名称
apiManager.getModelName()
....
```

#### 接口列表
| 功能名称        | 方法    |  支持状态  |
| --------          | -----:   | :----: |
| 扫描设备        | startScan(timeOut: Double)           |      ✅    |
| 停止到扫描      | stopScan()                          |      ✅    |
| 获取已连接设备         |   getConnectedDevice(uuid:[UUID])                    |     ✅  | 
| 通过device对象连接设备 |   connectBluetooth(device: BleDicoveryDevice)         |     ✅  | 
| 通过deiceID连接设备   |   connectDeviceBy(deviceId: String)                   |     ✅  | 
| 断开设备             |   disconnectDevice()                                   |     ✅  | 
| 注册事件监听          |   registerBleListener(listener: APIHeartRateObserver)  |   ✅    |
| 取消事件监听          |   unregisterBleListener(listener: APIHeartRateObserver)|     ✅  | 
| 获取设备电量          |   getDeviceBattery()                                   |     ✅  | 
| 获取厂商信息          |   getDeviceManufacturer()                               |     ✅  | 
| 获取ModelNum         |   getDeviceModelNum()                                  |     ✅  | 
| 获取硬件版本          |   getDeviceHardware()                                   |     ✅  | 
| 获取软件版本          |   getDeviceSoftware()                                    |     ✅  | 
| 获取固件版本          |   getDeviceFirmware()                                    |     ✅  | 
| 获取系统ID           |   getDeviceSystemID()                                     |     ✅  | 
| 设置心率最大阈值       |   setDeviceThreshold(max: UInt8)                         |     ✅  | 
| 获取序列号            |  getDeviceSerial()                                       |     ❌  | 
| 获取步频              |   getDeviceStepFrequency()                               |     ❌  | 
| 获取实时血氧           |   getRealTimeOxygen()                                     |     ❌  | 
| 同步时间              |   syncTime()                                              |     ✅  | 
| 主动读特征            |   readCharValue(charUUID: String)                         |     ✅  | 
| 主动设置特征监听      |   setCharNotify(charUUID: String, enabled: Bool)            |     ✅  | 
| 主动写特征           |   writeChar(charUUID: String, data:Data)                   |      ✅ | 
| 获取历史数据           |   ------                                    |     ❌  |
| <font color="red">Pod 0.0.7 </font>   |       |      |  
| 设置心率区间         |  setHeartRateThreshold(min: UInt8, max: UInt8) |     ✅ | 
| ota接口         |  startSendOTAFile(data: Data) 状态监听接口：bleOtaStauts(status: OtaStatus, progress: Float)；bleOtaError(error: OtaError)|     ✅ | 
| 接收手环按钮切换值         | armBandPlayStatusChange（被动） |     ✅ | 
| 长按5s接收解绑指令         | armBandUnbind（被动） |     ✅ | 
| 恢复出厂设置         | resetBand() |     ❌ | 

#### APIHeartRateObserver
这个代理类返回所有错误和数据
```swift
    //成功更新阈值
    func armBandMaxHeartRateUpdated()
    //成功同步时间
    func armBandSystemTimeUpdated()
    //返回电量
    func devicePower(power: String, device: BleDevice)
    //返回厂商信息
    func deviceManufacturerName(manufacturerName: String, device: BleDevice)
    //返回Mac地址
    func privateMacAddress(mac: String, device: BleDevice)
    //返回Model名称
    func deviceModelString(modelString: String, device: BleDevice)
    //返回硬件版本
    func deviceHardware(version: String, device: BleDevice)
    //返回固件版本
    func deviceFirmware(version: String, device: BleDevice)
    //返回系统ID
    func deviceSystemData(systemData: Data, device: BleDevice)
    //返回软件版本
    func deviceSoftware(version: String, device: BleDevice)
    //返回序列号
    func deviceSerialNumber(serialNumer: String, device: BleDevice)
    //返回心率
    func armBandRealTimeHeartRate(hRInfo: HRInfo, device: BleDevice)
    //返回当前设备连接状态
    func bleConnectStatus(status: DeviceBleStatus, device: BleDevice?)
    //返回实时步频
    func armBandStepFrequency(frequencyDic: [String:String], device: BleDevice)
    //返回实时血氧
    func armBandBloodOxygen(num: Int, device: BleDevice)
    //扫描中
    func didDiscoveryWith(discovery: [BleDicoveryDevice])
    //完成扫描
    func didFinishDiscoveryWith(discovery: [BleDicoveryDevice])
    //连接断连相关错误
    func bleConnectError(error: BleConnectError, device: BleDevice?)
    //通用错误
    func bleCommonError(error: BleCommonError)
    //蓝牙适配器状态
    func bleAvailability(status: BleAvailability)

```



## License
APIHearRate is released under the MIT License.
