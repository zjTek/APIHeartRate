//
//  ViewController.swift
//  testapihr
//
//  Created by Tek on 2023/1/6.
//

import APIHeartRate
import IHProgressHUD
import SnapKit
import SSZipArchive
import SwiftXLSX
import UIKit
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIHeartRateObserver {
    static let CONNECTED_KEY = "contected_device"
    var dataHeart: [HRInfo] = []

    var apiManager = APIHeartRateManager.instance
    var dataRow: [BleDicoveryDevice] = []
    var dataPaired: [BleDicoveryDevice] = []

    var isScaning = false
    var isConnected = false
    var isConnecting = false
    var connectMac = ""
    var cntUUID: [UUID] = []
    var curTime = 0
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = bgColor
        table.separatorStyle = .none
        table.register(DeviceCell.self, forCellReuseIdentifier: "CELL")
        return table
    }()

    lazy var txtFied2: UITextField = {
        let txtF = UITextField(frame: .zero)
        txtF.placeholder = "设备UUID"
        txtF.isUserInteractionEnabled = false
        return txtF
    }()

    lazy var connectBtn: TestBtn = {
        let btn = TestBtn(frame: CGRect.zero, title: "连接") { [weak self] _ in
            self?.connectById()
        }
        btn.isEnabled = false
        return btn
    }()

    lazy var disConBtn: TestBtn = {
        let btn = TestBtn(frame: CGRect.zero, title: "断开连接") { [weak self] _ in
            self?.apiManager.requestDisconnect()
        }
        btn.isEnabled = false
        return btn
    }()

    lazy var scanBtn: TestBtn = {
        let btn = TestBtn(frame: CGRect.zero, title: "扫描") { [weak self] _ in
            self?.statScan()
        }
        return btn
    }()

    lazy var exportBtn: TestBtn = {
        let btn = TestBtn(frame: CGRect.zero, title: "导出心率数据") { [weak self] _ in
            self?.exportExls()
        }
        btn.isEnabled = false
        return btn
    }()

    lazy var clearBtn: TestBtn = {
        let btn = TestBtn(frame: CGRect.zero, title: "清空心率数据") { [weak self] _ in
            self?.clearRateRecord()
        }
        btn.isEnabled = false
        return btn
    }()

    lazy var lightBtn: UILabel = {
        let bl = UILabel()
        bl.text = "保持屏幕常亮"
        return bl
    }()

    lazy var lightSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
        return sw
    }()
    
    lazy var apiBtn: TestBtn = {
        let btn = TestBtn(frame: CGRect.zero, title: "跳转API页面") { [weak self] _ in
            self?.gotoDevice()
        }
        btn.isEnabled = false
        return btn
    }()
    
    lazy var otaBtn: TestBtn = {
        let btn = TestBtn(frame: CGRect.zero, title: "开始OTA") { [weak self] _ in
            self?.statOTA()
        }
        return btn
    }()
    

    var bgColor = UIColor(red: 241 / 255.0, green: 241 / 255.0, blue: 241 / 255.0, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        apiManager.addObserver(observer: self)
        
        
        view.addSubview(tableView)
        view.addSubview(scanBtn)
        view.addSubview(disConBtn)
        view.addSubview(connectBtn)
        view.addSubview(txtFied2)
        view.addSubview(exportBtn)
        view.addSubview(clearBtn)
        view.addSubview(lightBtn)
        view.addSubview(lightSwitch)
        view.addSubview(apiBtn)
        view.addSubview(otaBtn)
        tableView.snp.makeConstraints { make in
            make.topMargin.equalTo(10)
            make.width.equalToSuperview()
            make.height.equalTo(320)
        }

        scanBtn.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(40)
            make.size.equalTo(CGSizeMake(150, 50))
            make.left.equalToSuperview().offset(16)
        }
        disConBtn.snp.makeConstraints { make in
            make.top.equalTo(scanBtn.snp.top)
            make.size.equalTo(CGSizeMake(150, 50))
            make.right.equalToSuperview().offset(-16)
        }
        connectBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(scanBtn.snp.bottom).offset(20)
            make.size.equalTo(CGSizeMake(80, 50))
        }
        txtFied2.snp.makeConstraints { make in
            make.top.equalTo(connectBtn.snp.top)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(connectBtn.snp.left)
            make.bottom.equalTo(connectBtn.snp.bottom)
        }
        exportBtn.snp.makeConstraints { make in
            make.top.equalTo(txtFied2.snp_bottomMargin).offset(20)
            make.left.equalTo(txtFied2)
            make.size.equalTo(CGSizeMake(140, 50))
        }
        clearBtn.snp.makeConstraints { make in
            make.top.equalTo(exportBtn)
            make.left.equalTo(exportBtn.snp.right).offset(30)
            make.size.equalTo(CGSizeMake(140, 50))
        }
        lightBtn.snp.makeConstraints { make in
            make.top.equalTo(exportBtn.snp.bottomMargin).offset(50)
            make.left.equalTo(exportBtn)
        }
        lightSwitch.snp.makeConstraints { make in
            make.left.equalTo(lightBtn.snp.right).offset(30)
            make.top.equalTo(lightBtn.snp.top)
        }
        apiBtn.snp.makeConstraints { make in
            make.left.equalTo(lightSwitch.snp.right).offset(30)
            make.top.equalTo(lightSwitch.snp.top)
            make.size.equalTo(CGSizeMake(140, 50))
        }
        otaBtn.snp.makeConstraints { make in
            make.left.equalTo(lightBtn).offset(30)
            make.top.equalTo(lightBtn.snp.bottomMargin).offset(50)
            make.size.equalTo(CGSizeMake(140, 50))
        }
        if let ud = UserDefaults.standard.object(forKey: ViewController.CONNECTED_KEY) as? [String] {
            for str in ud {
                if let uuid = UUID(uuidString: str) {
                    cntUUID.append(uuid)
                }
            }
        }
    }

    func statScan() {
        if isScaning {
            return
        }
        scanBtn.isEnabled = false
        IHProgressHUD.show()
        apiManager.startScan(timeOut: 3)
        if cntUUID.isEmpty {
            return
        }
        dataPaired = apiManager.getPairedDevices(uuid: cntUUID)
    }

    func clearRateRecord() {
        dataHeart = []
        clearBtn.isEnabled = false
        exportBtn.isEnabled = false
    }

    func updateRateRecord(v: HRInfo) {
        dataHeart.append(v)
        if !clearBtn.isEnabled {
            clearBtn.isEnabled = true
            exportBtn.isEnabled = true
        }
    }

    @objc
    func switchChanged(sender: UISwitch) {
        UIApplication.shared.isIdleTimerDisabled = sender.isOn
    }

    func exportExls() {
        if dataHeart.isEmpty {
            IHProgressHUD.showError(withStatus: "没有心率数据")
            return
        }
        IHProgressHUD.show()
        let book = XWorkBook()
        let sheet = book.NewSheet("心率数据")

        for row in 1 ... dataHeart.count {
            sheet.ForColumnSetWidth(row, 80)
            let item = dataHeart[row - 1]
            let cell = sheet.AddCell(XCoords(row: row, col: 1))
            cell.value = .text(item.time)
            let cell2 = sheet.AddCell(XCoords(row: row, col: 2))
            cell2.value = .text(item.rateStr)
        }
        let files = book.save("test.xlsx")
        print("<<<File XLSX generated!>>>")
        print("\(files)")
        if let lastIndex = files.lastIndex(of: "/") {
            let prefixPath = files[files.startIndex ..< lastIndex]
            let newPath = String(prefixPath) + "/rate.xlsx"
            let ok = SSZipArchive.createZipFile(atPath: newPath, withContentsOfDirectory: files, keepParentDirectory: false, withPassword: nil)
            IHProgressHUD.dismiss()
            if ok {
                _ = RemoveFile(path: files)
                let fileUrl = NSURL(fileURLWithPath: newPath)
                let shareV = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
                present(shareV, animated: true)
            }
        } else {
            IHProgressHUD.dismiss()
        }
    }

    private func RemoveFile(path pathfile: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: pathfile)
        } catch {
            print("Error remove file \(pathfile) : \(error.localizedDescription)")
            return false
        }
        return true
    }

    func connectById() {
        if isConnected {
            IHProgressHUD.show(withStatus: "设备已处于连接状态")
            return
        }
        if let v = txtFied2.text, !v.isEmpty {
            IHProgressHUD.showInfowithStatus("开始连接: \(v)")
            apiManager.connectToDeviceByDeviceId(deviceId: v)
            return
        }
        IHProgressHUD.show(withStatus: "deviceId有误")
    }
    
    func didDiscoveryWith(devices: [BleDicoveryDevice]) {
        print("found device: \(devices)")
    }

    func didFinishDiscoveryWith(devices: [BleDicoveryDevice]) {
        IHProgressHUD.dismiss()
        scanBtn.isEnabled = true
        isScaning = false
        print("found device: \(devices)")
        dataRow = devices
//        if (dataPaired.count > 0) {
//            for dev in dataRow {
//                for pd in dataPaired {
//                    if (pd == dev) {
//                        dataRow.remo
//                    }
//                }
//            }
//        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "已配对" : "新设备"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataPaired.count == 0 ? 1 : 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? dataRow.count : dataPaired.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if indexPath.section == 0 && indexPath.row >= dataRow.count {
//            return UITableViewCell()
//        } else if (indexPath.row >= dataPaired.count) {
//            return UITableViewCell()
//        }
        let model = indexPath.section == 1 ? dataPaired[indexPath.row] : dataRow[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as? DeviceCell {
            if connectMac == model.macAddress {
                cell.txtLbl.textColor = .green
                cell.txtLbl.text = (model.localName ) + "已连接"
            } else {
                cell.txtLbl.textColor = .black
                cell.txtLbl.text = model.localName
            }
            cell.detailLbl.text = "\(model.macAddress),RSSI:\(model.RSSI)"
            cell.subDetailLbl.text = model.deviceId
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isConnecting {
            return
        }
        if isConnected {
            return
        }
//        if indexPath.row >= dataRow.count {
//            return
//        }
        IHProgressHUD.show()
        isConnecting = true
        let model = indexPath.section == 1 ? dataPaired[indexPath.row] : dataRow[indexPath.row]
        apiManager.connectToDevice(device: model)
    }
    
    private func statOTA() {
        if let binFile = Bundle.main.url(forResource: "syd8811_hid_FirmwareV1.2", withExtension: "bin")
         {
            do {
                let d = try Data(contentsOf: binFile)
                apiManager.startSendOTAFile(data: d)
            } catch (let e) {
                print("err\(e)")
            }
           
        }
    }

    private func gotoDevice() {
        navigationController?.pushViewController(DeviceViewController(), animated: true)
    }

    func updateCntUD(uid: UUID?) {
        guard let hasV = uid else {
            return
        }
        if cntUUID.contains(hasV) {
            return
        }
        cntUUID.append(hasV)
        var strUUID: [String] = []
        for u in cntUUID {
            strUUID.append(u.uuidString)
        }
        UserDefaults.standard.set(strUUID, forKey: ViewController.CONNECTED_KEY)
    }

    // MARK: API Delegate

    func bleAvailability(status: BleAvailability) {
        switch status {
        case .available:
            scanBtn.isEnabled = true
            break
        case let .unavailable(cause):
            scanBtn.isEnabled = false
            if cause == .unauthorized {
                IHProgressHUD.showError(withStatus: "蓝牙权限未打开")
            } else if cause == .poweredOff {
                IHProgressHUD.showError(withStatus: "蓝牙开关未打开")
            } else {
                IHProgressHUD.showError(withStatus: "蓝牙状态错误")
            }
            break
        default:
            break
        }
    }

    func bleConnectError(error: APIHeartRate.BleConnectError, device: APIHeartRate.BleDevice?) {
        IHProgressHUD.dismiss()
        isConnecting = false
        switch error {
        case .scanFailed:
            IHProgressHUD.showError(withStatus: "扫描失败")
            scanBtn.isEnabled = true
            break
        default:
            break
        }
    }

    func bleCommonError(error: APIHeartRate.BleCommonError) {
    }

    func bleConnectStatus(status: DeviceBleStatus, device: BleDevice?) {
        IHProgressHUD.dismiss()
        isConnecting = false
        switch status {
        case .connected:
            IHProgressHUD.dismiss()
            scanBtn.isEnabled = false
            disConBtn.isEnabled = true
            apiBtn.isEnabled = true
            isConnected = true
            connectMac = device?.macAddress ?? ""
            txtFied2.text = device?.deviceId
            tableView.reloadData()
            //gotoDevice()
            curTime += 1
            updateCntUD(uid: device?.identifier)
            break
        case .disconnected:
            scanBtn.isEnabled = true
            disConBtn.isEnabled = false
            isConnected = false
            apiBtn.isEnabled = false
            connectMac = ""
            if !(txtFied2.text?.isEmpty ?? true) {
                connectBtn.isEnabled = true
            } else {
                connectBtn.isEnabled = false
            }
            tableView.reloadData()
            break
        default:
            break
        }
    }

    func armBandRealTimeHeartRate(hRInfo: APIHeartRate.HRInfo, device: APIHeartRate.BleDevice) {
        updateRateRecord(v: hRInfo)
    }

    func devicePower(power: String, device: APIHeartRate.BleDevice) {}

    func privateVersion(version: [String: String], device: APIHeartRate.BleDevice) {}

    func privateMacAddress(mac: String, device: APIHeartRate.BleDevice) {}

    func deviceSystemData(systemData: Data, device: APIHeartRate.BleDevice) {}

    func deviceModelString(modelString: String, device: APIHeartRate.BleDevice) {}

    func deviceSerialNumber(serialNumer: String, device: APIHeartRate.BleDevice) {}

    func deviceManufacturerName(manufacturerName: String, device: APIHeartRate.BleDevice) {}

    func deviceBaseInfo(baseInfo: APIHeartRate.FBKApiBaseInfo, device: APIHeartRate.BleDevice) {}

    func HRVResultData(hrvMap: [String: String], device: APIHeartRate.BleDevice) {}

    func armBandStepFrequency(frequencyDic: [String: String], device: APIHeartRate.BleDevice) {}

    func armBandTemperature(tempMap: [String: String], device: APIHeartRate.BleDevice) {}

    func armBandSPO2(spo2Map: [String: String], device: APIHeartRate.BleDevice) {}

    func armBandMaxHeartRateUpdated() {}

    func armBandSystemTimeUpdated() {}

    func armBandBloodOxygen(num: Int, device: APIHeartRate.BleDevice) {}

    func bleConnectLog(logString: String, device: APIHeartRate.BleDevice?) {
        print("\(logString)\(curTime)")
    }
    func deviceFirmware(version: String, device: APIHeartRate.BleDevice) {}

    func deviceHardware(version: String, device: APIHeartRate.BleDevice) {}

    func deviceSoftware(version: String, device: APIHeartRate.BleDevice) {}
    
    //MARK- OTA
    func bleOtaStauts(status: OtaStatus, progress: Float) {
        print("status:\(status),==== progress: \(progress)")
    }
    
    func bleOtaError(error: OtaError) {
        print("error\(error)")
    }
}
