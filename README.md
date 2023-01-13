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