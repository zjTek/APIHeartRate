
[toc]
## 扫描设备
### 1) 接口方法
```swift
startScan(timeOut: Double)
```

### 2) 接口描述：

* 扫描蓝牙设备

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|timeOut|扫描超时时间|Double|N|默认为空|

### 5) 结果回调:

```swift
 func didDiscoveryWith(devices: [BleDicoveryDevice]) {}
```


### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|devices|扫描结果数组|[BleDicoveryDevice]|-|-|
---


## 断开连接

### 1) 接口方法
```swift
func disconnectDevice()
```

### 2) 接口描述：

* 主动断开蓝牙设备

### 3) 参数: -

### 5) 结果回调:

```swift
 func bleConnectStatus(status: DeviceBleStatus, device: BleDevice?) {}
```


### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|status|蓝牙设备状态|DeviceBleStatus|-|connecting connected disconnecting disconnected 四个状态|
|device|连接的蓝牙设备|BleDevice|-|断开后为空|
---

## 注册事件监听

### 1) 接口方法
```swift
func registerBleListener(listener: APIHeartRateObserver)
```

### 2) 接口描述：

* 注册回调，所有的返回值都从以上回调中获取

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|listener|传入实现该协议的对象|APIHeartRateObserver|Y||

### 5) 结果回调: -

### 6) 结果参数说明: -
---

## 取消事件监听

### 1) 接口方法
```swift
func unregisterBleListener(listener: APIHeartRateObserver)
```

### 2) 接口描述：

* 取消回调事件的监听

### 3) 参数:

|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|listener|传入实现该协议的对象|APIHeartRateObserver|Y||

### 5) 结果回调: -
### 6) 结果参数说明: -
---

## 读取设备电量

### 1) 接口方法
```swift
func getDeviceBattery()
```

### 2) 接口描述：

* 读取设备电量

### 3) 参数: -

### 5) 结果回调:

```swift
 func devicePower(power: String, device: BleDevice) {}
```


### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|power|电量值|String|-|-|
---

## 制造商信息

### 1) 接口方法
```swift
func getDeviceManufacturer()
```

### 2) 接口描述：

* 读取制造商信息

### 3) 参数: -

### 5) 结果回调:

```swift
  func deviceManufacturerName(manufacturerName: String, device: BleDevice)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|manufacturerName|厂商名称|String|-|-|
|device|当前连接的设备|BleDevice|-|-|
---

## Model信息

### 1) 接口方法
```swift
func getDeviceModelNum()
```

### 2) 接口描述：

* 读取型号信息

### 3) 参数: -

### 5) 结果回调:

```swift
 func deviceModelString(modelString: String, device: BleDevice)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|modelString|型号信息|String|-|-|
|device|当前连接的设备|BleDevice|-|-|
---
## 硬件版本

### 1) 接口方法
```swift
func getDeviceHardware()
```

### 2) 接口描述：

* 读取制硬件版本信息

### 3) 参数: -

### 5) 结果回调:

```swift
 func deviceHardware(version: String, device: BleDevice)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|version|硬件版本|String|-|-|
|device|当前连接的设备|BleDevice|-|-|
---

## 软件版本

### 1) 接口方法
```swift
func getDeviceSoftware()
```

### 2) 接口描述：

* 读取设备软件版本信息

### 3) 参数: - 

### 5) 结果回调:

```swift
func deviceSoftware(version: String, device: BleDevice)
```


### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|version|软件版本|String|-|-|
|device|当前连接设备|BleDevice|-|-|
---
## 固件信息

### 1) 接口方法
```swift
func getDeviceFirmware()
```

### 2) 接口描述：

* 读取固件信息

### 3) 参数: -

### 5) 结果回调:

```swift
 func deviceFirmware(version: String, device: BleDevice)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|version|固件版本|String|-|-|
|device|当前连接的设备|BleDevice|-|-|
---
## 系统ID

### 1) 接口方法
```swift
func getDeviceSystemID()
```

### 2) 接口描述：

* 读取设备系统ID信息

### 3) 参数: -

### 5) 结果回调:

```swift
  func deviceSystemData(systemData: Data, device: BleDevice)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|systemData|系统ID|Data|-|7字节的值|
|device|当前连接的设备|BleDevice|-|-|
---
## <font color=red>~~序列号信息(未实现)~~</font>

### 1) 接口方法
```swift
func getDeviceSerial()
```

### 2) 接口描述：

* 读取设备序列号信息

### 3) 参数: -

### 5) 结果回调:

```swift
 func deviceSerialNumber(serialNumer: String, device: BleDevice)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|serialNumer|序列号|String|-|-|
|device|当前连接的设备|BleDevice|-|-|
---
## <font color=red>~~步频(未实现)~~</font>

### 1) 接口方法
```swift
func getDeviceStepFrequency()
```

### 2) 接口描述：

* 获取步频信息

### 3) 参数: -

### 5) 结果回调:

```swift
func armBandStepFrequency(frequencyDic: [String: String], device: BleDevice) {}
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|frequencyDic|步频字典|[String:String]|-|-|
|device|当前连接的设备|BleDevice|-|-|
---
## <font color=red>~~实时血氧(未实现)~~</font>

### 1) 接口方法
```swift
func getRealTimeOxygen()
```

### 2) 接口描述：

* 获取实时血氧

### 3) 参数: -

### 5) 结果回调:

```swift
func armBandBloodOxygen(num: Int, device: BleDevice) {}
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|num|血氧值|Int|-|-|
|device|当前连接的设备|BleDevice|-|-|
---

## 同步时间

### 1) 接口方法
```swift
func syncTime()
```

### 2) 接口描述：

* 同步当前设备时间

### 3) 参数: -

### 5) 结果回调:

```swift
func armBandSystemTimeUpdated() {}
```
### 6) 结果说明： -
---
## 心跳阈值

### 1) 接口方法
```swift
func setHeartRateThreshold(min: UInt8,max: UInt8)
```

### 2) 接口描述：

* 设置心跳阈值，心跳小于左边界为绿灯，大于右边界为红灯

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|min|左边界|UInt8|Y|-|
|max|右边界|UInt8|N|默认为0|

### 5) 结果回调:

```swift
func armBandMaxHeartRateUpdated() {}
```
---
## 切换播放状态

### 1) 接口方法： -

### 2) 接口描述：

* 点击设备按钮，切换状态，没有主动调用接口

### 3) 参数 -

### 5) 结果回调:

```swift
func armBandPlayStatusChange() {} //每次点按钮均回调一次
```
---
## 长按配对

### 1) 接口方法： -

### 2) 接口描述：

* 长按关机键关机并保持不放5s，设备进入配对模式，并传回结果回调
* 固件版本>=v1.2

### 3) 参数 -

### 5) 结果回调:

```swift
func armBandUnbind() {} //进入配对模式后回调一次
```
---

## 设备充电状态

### 1) 接口方法： -

### 2) 接口描述：

* 此接口也是被动回调，一共有充电中、充电完成、未充电三个状态

### 3) 参数 -

### 5) 结果回调:
```swift
 func batteryStatus(state: BatteryStatus) {}
```
### 6) 返回结果说明：
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|state|充电状态|BatteryStatus|-|normal,charging,full,unknow|
---
## 心率测量中状态回调

### 1) 接口方法： -

### 2) 接口描述：

* 心率测量中状态回调，此时不出心率值

### 3) 参数 -

### 5) 结果回调:

```swift
func heartRateInMeasuring()
```
---
## <font color=red>~~恢复出厂设置(未实现)~~</font>

### 1) 接口方法
```swift
func resetBand()
```

### 2) 接口描述：

* 恢复出厂设置

### 3) 参数: -

### 5) 结果回调: -
### 6) 结果说明： -
---
## OTA

### 1) 接口方法
```swift
func startSendOTAFile(data: Data)
```

### 2) 接口描述：

* 进行OTA操作

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|data|ota文件数据|Data|Y|-|

### 5) 结果回调:

```swift
func bleOtaStauts(status: OtaStatus, progress: Float)；
func bleOtaError(error: OtaError)
```

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|status|ota状态|OtaStatus|-|start,erase,inprogress,finished,failed|
|progress|更新进度|Float|-|-|
|error|异常信息|OtaError|-|invalidFile,interupted,invalidResponse,reSend|


<font color=red>============================== 新增接口==============</font>

## 设置运动模式

### 1) 接口方法
```swift
func setBandSportMode(mode: SportMode)
```

### 2) 接口描述：

* 设置设备运动模式

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|mode|SportMode.normal:日常模式，SportMode.sport运动模式|SportMode|Y|-|

### 5) 结果回调:

```swift
func bandSportModeChanged()
```

### 6) 结果参数说明: -

## 读取运动模式

### 1) 接口方法
```swift
func queryBandSportMode()
```

### 2) 接口描述：

* 读取设备运动模式

### 3) 参数: -
### 5) 结果回调:

```swift
func deviceSportModeInfo(mode: SportMode)
```

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|mode|运动模式|SportMode|-|normal,sport|


## 心率汇总

### 1) 接口方法
```swift
func queryHeartRateRecord(startTime: Int, endTime:Int)
```

### 2) 接口描述：

* 读取心率汇总数据

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|startTime|开始时段|Int|Y|0-23|
|endTime|结束时段|Int|Y|0-23|
### 5) 结果回调:

```swift
func deviceHeartRateRecordInfo(info: HeartRateInfo)
```

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|info|心率信息数据|HeartRateInfo|-|HeartRateInfo.max 最高, HeartRateInfo.min 最低, HeartRateInfo.average 平均|

## 步数汇总

### 1) 接口方法
```swift
func queryStepRecord(startTime: Int, endTime:Int)
```

### 2) 接口描述：

* 读取心率汇总数据

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|startTime|开始时段|Int|Y|0-23|
|endTime|结束时段|Int|Y|0-23|
### 5) 结果回调:

```swift
func deviceStepRecordInfo(info: StepInfo)
```

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|info|步数信息数据|StepInfo|-|StepInfo.total 一天总步数, StepInfo.current 分时段步数|


## 睡眠汇总

### 1) 接口方法
```swift
func querySleepRecord()
```

### 2) 接口描述：

* 读取心率汇总数据

### 3) 参数: -
### 5) 结果回调:

```swift
func deviceSleepRecordInfo(info: SleepInfo)
```

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|info|步数信息数据|SleepInfo|-|SleepInfo.total 一天睡眠时间, SleepInfo.deep 深睡眠，SleepInfo.deep 浅睡眠，SleepInfo.wake 清醒次数|

## 血氧汇总

### 1) 接口方法
```swift
func queryOxgenBloodRecord(startTime: Int, endTime:Int)
```

### 2) 接口描述：

* 读取心率汇总数据

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|startTime|开始时段|Int|Y|0-23|
|endTime|结束时段|Int|Y|0-23|
### 5) 结果回调:

```swift
func deviceOxgenBloodRecordInfo(info: OxgenBloodInfo)
```

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|info|血氧信息数据|OxgenBlood|-|OxgenBlood.max 最高, OxgenBlood.min 最低, OxgenBlood.average 平均|