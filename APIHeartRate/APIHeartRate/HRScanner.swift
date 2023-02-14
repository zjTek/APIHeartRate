//
//  BluetoothKit
//
//  Copyright (c) 2015 Rasmus Taulborg Hummelmose - https://github.com/rasmusth
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import CoreBluetooth

internal class HRScanner: HRCBCentralManagerDiscoveryDelegate {

    // MARK: Type Aliases

    internal typealias ScanCompletionHandler = ((_ result: [BleDicoveryDevice]?, _ error: HRError?) -> Void)

    // MARK: Enums

    internal enum HRError: Error {
        case noCentralManagerSet
        case busy
        case interrupted
        case endByUser
    }

    // MARK: Properties

    internal var centralManager: CBCentralManager!
    private var busy = false
    private var scanHandlers: (progressHandler: HRCentral.ScanProgressHandler?, completionHandler: ScanCompletionHandler )?
    private var discoveries = [BleDicoveryDevice]()
    private var durationTimer: Timer?

    // MARK: Internal Functions

    internal func scanWithDuration(_ duration: TimeInterval, updateDuplicates: Bool, progressHandler: HRCentral.ScanProgressHandler? = nil, completionHandler: @escaping ScanCompletionHandler) throws {
        do {
            try validateForActivity()
            busy = true
            scanHandlers = ( progressHandler: progressHandler, completionHandler: completionHandler)
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: updateDuplicates]
            centralManager.scanForPeripherals(withServices: nil, options: options)
            if duration > 0 {
                durationTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(HRScanner.durationTimerElapsed), userInfo: nil, repeats: false)
            }
        } catch let error {
            throw error
        }
    }

    internal func interruptScan() {
        guard busy else {
            return
        }
        endScan(.interrupted)
    }

    // MARK: Private Functions

    private func validateForActivity() throws {
        guard !busy else {
            throw HRError.busy
        }
        guard centralManager != nil else {
            throw HRError.noCentralManagerSet
        }
    }

    @objc private func durationTimerElapsed() {
        endScan(nil)
    }

    public func endScan(_ error: HRError?) {
        invalidateTimer()
        centralManager.stopScan()
        let completionHandler = scanHandlers?.completionHandler
        let discoveries = self.discoveries
        scanHandlers = nil
        self.discoveries.removeAll()
        busy = false
        completionHandler?(discoveries, error)
    }

    private func invalidateTimer() {
        if let durationTimer = self.durationTimer {
            durationTimer.invalidate()
            self.durationTimer = nil
        }
    }

    // MARK: BKCBCentralManagerDiscoveryDelegate

    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard busy else {
            return
        }
        guard let macStr = notTargetDevice(adv: advertisementData) else {
            return
        }
        UserDefaults.standard.set(macStr, forKey: peripheral.identifier.uuidString)
        let RSSI = Int(truncating: RSSI)
        let remotePeripheral = BleDevice(identifier: peripheral.identifier, peripheral: peripheral)
        remotePeripheral.macAddress = macStr
        let nameStr = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        var discovery = BleDicoveryDevice(advertisementData: advertisementData, remotePeripheral: remotePeripheral, RSSI: RSSI, macAddress: macStr, name: nameStr)
        if let index = discoveries.firstIndex(of: discovery) {
            discoveries[index] = discovery
        } else {
            discoveries.append(discovery)
        }
        scanHandlers?.progressHandler?(discoveries)
    }
    
    internal func notTargetDevice(adv: [String: Any]) -> String? {
        guard let manufactureData = adv[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return nil
        }
        if manufactureData.count < 7 {return nil}
        let flag:UInt16 = UInt16(manufactureData[0]) << 8 | UInt16(manufactureData[1])
        if (flag != 0x0585 && flag != 0x0185){
            return  nil
        }
        return String.init(format: "%02X:%02X:%02X:%02X:%02X:%02X", manufactureData[2],manufactureData[3],manufactureData[4],manufactureData[5],manufactureData[6],manufactureData[7])
        
    }

}
