
[toc]
# APIHeartRate
Android Bluetooth Low Energy
## Usage

- #### 初始化
    
        FBKApiHeartRate.initConfig(application)


- #### 传入callback

        FBKApiHeartRate.setBleCallBack(object : FBKBleCallBack {...})
                       .setBleCallBack(object : FBKBasicInfoCallBack{..})
                       .setHeartRateCallBack(javaClass.name,object : FBKHearRateCallBack{..})
        callback 可以单独设置
        FBKBleCallBack 与 FBKBasicInfoCallBack 只能设置一次，多次设置会覆盖
        FBKHearRateCallBack 可以设置多次，退出相关页面后，记得调用removeHeartRateCallBack

## 扫描设备
### 1) 接口方法
```kotlin
fun startScan(timeOut: Double)
```
### 2) 接口描述：

* 扫描蓝牙设备

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|timeOut|扫描超时时间|Long|N|默认5000，单位毫秒|

### 5) 结果回调:

```kotlin
 fun onDiscoveryDevice(result: FBKBleDevice)
 fun onFinishDiscovery() //扫描结束
 fun onScanError(error: String?, managerController: FBKManagerController?)
```


### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|result|扫描结果|FBKBleDevice|-|多次回调|
|error|扫描失败原因|String|-|-|
|managerController|蓝牙控制器对象|FBKManagerController|-|-|
---

## 停止扫描
### 1) 接口方法
```kotlin
stopScan()
```
### 2) 接口描述：

* 停止扫描

### 3) 参数: -

### 5) 结果回调: -


### 6) 结果参数说明: -
---

## 连接设备

### 1) 接口方法
```kotlin
  fun connectBluetooth(bluetoothDevice: BluetoothDevice?, retryTime: Int? = 0)
```

### 2) 接口描述：

* 主动连接设备

### 3) 参数: 
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|bluetoothDevice|要连接的设备|BluetoothDevice|Y||
|retryTime|失败重连次数|Int|N||
### 5) 结果回调:

```kotlin
 fun bleConnectStatus(
        deviceStatus: FBKBleDeviceStatus?,
        baseMethod: FBKApiBaseMethod?
    )
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|deviceStatus|蓝牙设备状态|FBKBleDeviceStatus|-|BleDisconnecting BleDisconnected BleConnecting BleConnected|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---

## 注册事件监听

### 1) 接口方法
```kotlin
fun registerBleListenerReceiver()
```

### 2) 接口描述：

* 注册广播监听，返回广播中的蓝牙状态和日志，一般用不着

### 3) 参数: -

### 5) 结果回调: -

### 6) 结果参数说明: -
---

## 取消事件监听

### 1) 接口方法
```kotlin
fun unregisterBleListenerReceiver()
```

### 2) 接口描述：

* 取消回调事件的监听

### 3) 参数: -

### 5) 结果回调: -
### 6) 结果参数说明: -
---

## 切换蓝牙监听回调状态

### 1) 接口方法
```kotlin
fun toggleNotifyWith(status: Boolean, type: FBKArmBandCmd = FBKArmBandCmd.HeartRate)
```

### 2) 接口描述：

* 切换蓝牙返回值监听状态，FBKArmBandCmd.HeartRate(心率),FBKArmBandCmd.Notify(通用值监听)

### 3) 参数: -

### 5) 结果回调: -

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|status|是否开启监听|Boolean|-|-|
|type|需要切换的监听类型|FBKArmBandCmd|-|-|
---

## 读取设备电量

### 1) 接口方法
```kotlin
fun readDeviceBatteryPower()
```

### 2) 接口描述：

* 读取设备电量

### 3) 参数: -

### 5) 结果回调:

```kotlin
 fun batteryPower(value: Int, baseMethod: FBKApiBaseMethod?)
```


### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|value|电量值|Int|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---

## 制造商信息

### 1) 接口方法
```kotlin
fun readManufacturerName()
```

### 2) 接口描述：

* 读取制造商信息

### 3) 参数: -

### 5) 结果回调:

```kotlin
 fun deviceManufacturerName(name: String?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|name|厂商名称|String|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---

## Model信息

### 1) 接口方法
```kotlin
fun readModelString()
```

### 2) 接口描述：

* 读取型号信息

### 3) 参数: -

### 5) 结果回调:

```kotlin
 fun deviceModelString(model: String?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|model|型号信息|String|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---
## 硬件版本

### 1) 接口方法
```kotlin
 fun readHardwareVersion()
```

### 2) 接口描述：

* 读取制硬件版本信息

### 3) 参数: -

### 5) 结果回调:

```kotlin
 fun hardwareVersion(version: String?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|version|硬件版本|String|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---

## 软件版本

### 1) 接口方法
```kotlin
fun readSoftwareVersion()
```

### 2) 接口描述：

* 读取设备软件版本信息

### 3) 参数: - 

### 5) 结果回调:

```kotlin
fun softwareVersion(version: String?, baseMethod: FBKApiBaseMethod?)
```


### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|version|软件版本|String|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---
## 固件信息

### 1) 接口方法
```kotlin
fun readFirmwareVersion()
```

### 2) 接口描述：

* 读取固件信息

### 3) 参数: -

### 5) 结果回调:

```kotlin
fun firmwareVersion(version: String?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|version|固件版本|String|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---
## 系统ID

### 1) 接口方法
```kotlin
fun readSystemId()
```

### 2) 接口描述：

* 读取设备系统ID信息

### 3) 参数: -

### 5) 结果回调:

```kotlin
fun deviceSystemID(data: ByteArray?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|data|系统ID|ByteArray|-|7字节的值|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---
## <font color=red>~~序列号信息(未实现)~~</font>

### 1) 接口方法
```kotlin
fun getDeviceSerial()
```

### 2) 接口描述：

* 读取设备序列号信息

### 3) 参数: -

### 5) 结果回调:

```kotlin
 fun deviceSerialNumber(version: String?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|serialNumer|序列号|String|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---
## <font color=red>~~步频(未实现)~~</font>

### 1) 接口方法
```kotlin
fun getDeviceStepFrequency()
```

### 2) 接口描述：

* 获取步频信息

### 3) 参数: -

### 5) 结果回调:

```kotlin
fun deviceStepFrequency(id: Int?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|id|步频|Int|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---
## <font color=red>~~实时血氧(未实现)~~</font>

### 1) 接口方法
```kotlin
fun getRealTimeOxygen()
```

### 2) 接口描述：

* 获取实时血氧

### 3) 参数: -

### 5) 结果回调:

```kotlin
fun deviceOxygen(id: Int?, baseMethod: FBKApiBaseMethod?)
```
### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|id|血氧值|Int|-|-|
|baseMethod|接口实例对象|FBKApiBaseMethod|-|-|
---

## 同步时间

### 1) 接口方法
```kotlin
fun syncTime()
```

### 2) 接口描述：

* 同步当前设备时间

### 3) 参数: -

### 5) 结果回调:

```kotlin
fun deviceTimeSynced()
```
### 6) 结果说明： -
---
## 心跳阈值

### 1) 接口方法
```kotlin
fun setDeviceThreshold(min:Int, max: Int)
```

### 2) 接口描述：

* 设置心跳阈值，心跳小于左边界为绿灯，大于右边界为红灯

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|min|左边界|UInt8|Y|-|
|max|右边界|UInt8|N|默认为0|

### 5) 结果回调:

```kotlin
fun deviceThresholdChanged()
```
---
## 切换播放状态

### 1) 接口方法： -

### 2) 接口描述：

* 点击设备按钮，切换状态，没有主动调用接口

### 3) 参数 -

### 5) 结果回调:

```kotlin
fun armBandPlayStatusChange() //每次点按钮均回调一次
```
---
## 长按配对

### 1) 接口方法： -

### 2) 接口描述：

* 长按关机键关机并保持不放5s，设备进入配对模式，并传回结果回调
* 固件版本>=v1.2

### 3) 参数 -

### 5) 结果回调:

```kotlin
fun armBandUnbind() //进入配对模式后回调一次
```
---
## 心率测量中状态回调

### 1) 接口方法： -

### 2) 接口描述：

* 心率测量中状态回调，此时不出心率值

### 3) 参数 -

### 5) 结果回调:

```kotlin
fun heartRateInMeasuring()
```
---

## 设备充电状态

### 1) 接口方法： -

### 2) 接口描述：

* 此接口也是被动回调，一共有充电中、充电完成、未充电三个状态

### 3) 参数 -

### 5) 结果回调:
```kotlin
fun  batteryStatus(state: BatteryStatus)
```
### 6) 返回结果说明：
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|state|充电状态|BatteryStatus|-|default未在充电,charing：充电中,fullfilled： 已充满|
---
## <font color=red>~~恢复出厂设置(未实现)~~</font>

### 1) 接口方法
```kotlin
resetBand()
```

### 2) 接口描述：

* 恢复出厂设置

### 3) 参数: -

### 5) 结果回调: -
### 6) 结果说明： -
---
## OTA

### 1) 接口方法
```kotlin
fun startOTA(file: ByteArray?)
```

### 2) 接口描述：

* 进行OTA操作

### 3) 参数:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|file|ota文件数据|ByteArray|Y|-|

### 5) 结果回调:

```kotlin
fun bleOtaLog(state: OtaStatus, progress: Float)
fun bleOtaError(error: OtaError)
```

### 6) 结果参数说明:
|字段名称       |字段说明         |类型            |必填            |备注     |
| -------------|:--------------:|:--------------:|:--------------:| ------:|
|status|ota状态|OtaStatus|-|Erazing,Start,Inprogress,Finished|
|progress|更新进度|Float|-|-|
|error|异常信息|OtaError|-|Failed,InvalidFile,ReSend|

