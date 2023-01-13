

import Foundation

internal func == (lhs: HRConnectionAttempt, rhs: HRConnectionAttempt) -> Bool {
    return (lhs.remotePeripheral.identifier == rhs.remotePeripheral.identifier)
}

internal class HRConnectionAttempt: Equatable {

    // MARK: Properties

    internal let timer: Timer
    internal let remotePeripheral: BleDevice
    internal let completionHandler: ((_ peripheralEntity: BleDevice, _ error: HRConnectionPool.HRError?) -> Void)

    // MARK: Initialization

    internal init(remotePeripheral: BleDevice, timer: Timer, completionHandler: @escaping ((BleDevice, HRConnectionPool.HRError?) -> Void)) {
        self.remotePeripheral = remotePeripheral
        self.timer = timer
        self.completionHandler = completionHandler
    }
}
