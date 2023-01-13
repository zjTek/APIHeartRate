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

internal protocol HRCBCentralManagerStateDelegate: AnyObject {
    func centralManagerDidUpdateState(_ central: CBCentralManager)
}

internal protocol HRCBCentralManagerDiscoveryDelegate: AnyObject {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber)
}

internal protocol HRCBCentralManagerConnectionDelegate: AnyObject {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
}

internal class HRCBCentralManagerDelegateProxy: NSObject, CBCentralManagerDelegate {

    // MARK: Initialization

    internal init(stateDelegate: HRCBCentralManagerStateDelegate, discoveryDelegate: HRCBCentralManagerDiscoveryDelegate, connectionDelegate: HRCBCentralManagerConnectionDelegate) {
        self.stateDelegate = stateDelegate
        self.discoveryDelegate = discoveryDelegate
        self.connectionDelegate = connectionDelegate
        super.init()
    }

    // MARK: Properties

    internal weak var stateDelegate: HRCBCentralManagerStateDelegate?
    internal weak var discoveryDelegate: HRCBCentralManagerDiscoveryDelegate?
    internal weak var connectionDelegate: HRCBCentralManagerConnectionDelegate?

    // MARK: CBCentralManagerDelegate

    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateDelegate?.centralManagerDidUpdateState(central)
    }

    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        discoveryDelegate?.centralManager(central, didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }

    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionDelegate?.centralManager(central, didConnect: peripheral)
    }

    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionDelegate?.centralManager(central, didFailToConnect: peripheral, error: error)
    }

    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionDelegate?.centralManager(central, didDisconnectPeripheral: peripheral, error: error)
    }

}
