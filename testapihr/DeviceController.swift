//
//  DeviceController.swift
//  testapihr
//
//  Created by Tek on 2023/1/12.
//


import IHProgressHUD
import UIKit
import APIHeartRate
class DeviceViewController: UIViewController, LoggerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, APIHeartRateObserver {
 

    func didDiscoveryWith(discovery: [APIHeartRate.BleDicoveryDevice]) {}

    func didFinishDiscoveryWith(discovery: [APIHeartRate.BleDicoveryDevice]) {}
    func bleAvailability(status: BleAvailability) {}
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        apiManager.removeObserver(observer: self)
    }

    deinit {
        print("de init")
    }

    var btnArray = ["获取电量", "Manufacturer", "Model", "Hardware", "FirmWare", "Software", "SysID", "时间同步", "序列号", "实时步频", "实时血氧"]
    var apiManager = APIHeartRateManager.instance

    lazy var mCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 50)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let table = UICollectionView(frame: .zero, collectionViewLayout: layout)
        table.delegate = self
        table.dataSource = self
        table.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        table.register(BtnCell.self, forCellWithReuseIdentifier: "BTN")
        return table
    }()

    lazy var txtFied1: UITextField = {
        let txtF = UITextField(frame: .zero)
        txtF.keyboardType = .numberPad
        txtF.placeholder = "输入震动阈值"
        return txtF
    }()

    lazy var logTxtView: UITextView = {
        let txtView = UITextView(frame: .zero)
        txtView.isEditable = false
        txtView.alwaysBounceVertical = true
        return txtView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        Logger.delegate = self
        apiManager.addObserver(observer: self)
        logTxtView.frame = CGRectMake(0, 0, view.frame.width, 300)
        mCollectionView.frame = CGRectMake(0, 310, view.frame.width, 290)
        txtFied1.frame = CGRectMake(10, 580, 200, 50)
        let sendBtn = TestBtn(frame: CGRectMake(220, 580, 80, 50), title: "设置") { [weak self] _ in
            self?.setVibrateMaxValue()
        }
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, view.frame.width, 44))
        let barBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishInputValue))
        toolbar.items = [barBtn]
        txtFied1.inputAccessoryView = toolbar
        view.addSubview(logTxtView)
        view.addSubview(mCollectionView)
        view.addSubview(txtFied1)
        view.addSubview(sendBtn)
    }

    @objc
    func finishInputValue() {
        txtFied1.resignFirstResponder()
    }

    func loggerDidLogString(_ string: String) {
        if logTxtView.text.count > 0 {
            logTxtView.text = logTxtView.text + ("\n" + string)
        } else {
            logTxtView.text = string
        }
        logTxtView.scrollRangeToVisible(NSRange(location: logTxtView.text.count - 1, length: 1))
    }

    func setVibrateMaxValue() {
        guard let v = txtFied1.text else {
            Logger.log("阈值输入有误")
            return
        }
        if v.isEmpty {
            Logger.log("阈值输入有误")
            return
        }
        apiManager.setHeartRateMax(heartRateMax: UInt8(v) ?? 0)
    }

    // MARK: Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return btnArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BTN", for: indexPath) as? BtnCell {
            cell.setTxt(txt: btnArray[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item > 7 {
            IHProgressHUD.showError(withStatus: "此功能开发中")
            return
        }
        Logger.log("开始 \(btnArray[indexPath.item]):")
        switch indexPath.item {
        case 0:
            apiManager.readDeviceBatteryPower()
            break
        case 1:
            apiManager.getManufacturerName()
            break
        case 2:
            apiManager.getModelName()
            break
        case 3:
            apiManager.getHardwareVersion()
            break
        case 4:
            apiManager.getFirmwareVersion()
            break
        case 5:
            apiManager.getSoftwareVersion()
            break
        case 6:
            apiManager.getSystemID()
            break
        case 7:
            apiManager.syncDeviceTime()
            break
        case 8:
            apiManager.getSerialNum()
            break
        case 9:
            apiManager.getStepFrequency()
            break
        case 10:
            apiManager.getRTOxygen()
            break
        default:
            break
        }
    }

    func showAlert() {
        let alertCon = UIAlertController(title: "提示", message: "手环已已断开", preferredStyle: .alert)
        alertCon.addAction(UIAlertAction(title: "好的", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alertCon, animated: true)
    }

    // MARK: API Delegate
    func bleConnectError(error: APIHeartRate.BleConnectError, device: APIHeartRate.BleDevice?) {
        var e = ""
        switch error {
        case .deviceNotConnected:
            e = "设备未连接"
            break
        case .deviceNotFound:
            e = "未找到设备"
            break
        case .scanFailed:
            e = "扫描失败"
            break
        case let .failedToDisconnect(underlineError):
            e = "断连失败：" + (underlineError?.localizedDescription ?? "")
            break
        case .failedToConnectDueToTimeout:
            e = "连接超时"
            break
        default:
            e = "未知错误"
            break
        }
        Logger.log(e)
    }
    
    func bleCommonError(error: APIHeartRate.BleCommonError) {
        var logS = ""
        switch error {
        case .devieNotConnected:
            logS = "设备未连接"
            break
        case .deviceNotFound:
            logS = "未找到设备"
            break
        case .serviceNotFound:
            logS = "未找到该服务"
            break
        case .receivedWrongData:
            logS = "收到错误数据"
            break
        default:
            logS = "发生未知错误"
            break
        }
        Logger.log(logS)
    }

    func bleConnectStatus(status: APIHeartRate.DeviceBleStatus, device: APIHeartRate.BleDevice?) {
        switch status {
        case .disconnected:
            showAlert()
            break
        default:
            break
        }
    }

    func devicePower(power: String, device: APIHeartRate.BleDevice) {
        Logger.log("电量为： \(power)")
    }

    func bleConnectLog(logString: String, device: APIHeartRate.BleDevice?) {
        Logger.log(logString)
    }

    func privateVersion(version: [String: String], device: APIHeartRate.BleDevice) {
        Logger.log("私有版本为： \(version)")
    }

    func privateMacAddress(mac: String, device: APIHeartRate.BleDevice) {
        Logger.log("Mac地址为： \(mac)")
    }

    func deviceSystemData(systemData: Data, device: APIHeartRate.BleDevice) {
        Logger.log("系统ID为： \(systemData)")
    }

    func deviceFirmware(version: String, device: APIHeartRate.BleDevice) {
        Logger.log("固件版本： \(version)")
    }

    func deviceHardware(version: String, device: APIHeartRate.BleDevice) {
        Logger.log("硬件版本： \(version)")
    }

    func deviceSoftware(version: String, device: APIHeartRate.BleDevice) {
        Logger.log("软件版本： \(version)")
    }

    func deviceModelString(modelString: String, device: APIHeartRate.BleDevice) {
        Logger.log("moodel为： \(modelString)")
    }

    func deviceSerialNumber(serialNumer: String, device: APIHeartRate.BleDevice) {
        Logger.log("serial为： \(serialNumer)")
    }

    func deviceManufacturerName(manufacturerName: String, device: APIHeartRate.BleDevice) {
        Logger.log("Manufacture为： \(manufacturerName)")
    }

    func armBandMaxHeartRateUpdated() {
        Logger.log("阈值更新成功")
    }

    func armBandSystemTimeUpdated() {
        Logger.log("系统时间同步成功")
    }

    func armBandRealTimeHeartRate(hRInfo: APIHeartRate.HRInfo, device: APIHeartRate.BleDevice) {
        Logger.log("心率为： \(hRInfo.rateStr)")
    }

    func deviceBaseInfo(baseInfo: APIHeartRate.FBKApiBaseInfo, device: APIHeartRate.BleDevice) { }

    func HRVResultData(hrvMap: [String: String], device: APIHeartRate.BleDevice) {}

    func armBandStepFrequency(frequencyDic: [String: String], device: APIHeartRate.BleDevice) {}

    func armBandTemperature(tempMap: [String: String], device: APIHeartRate.BleDevice) {}

    func armBandSPO2(spo2Map: [String: String], device: APIHeartRate.BleDevice) {}
    func armBandBloodOxygen(num: Int, device: APIHeartRate.BleDevice) {}
}
