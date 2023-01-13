
import CoreBluetooth

public func == (lhs: BleDicoveryDevice, rhs: BleDicoveryDevice) -> Bool {
    return lhs.macAddress == rhs.macAddress || lhs.remotePeripheral == rhs.remotePeripheral
}

/**
    A discovery made while scanning, containing a peripheral, the advertisement data and RSSI.
*/
public struct BleDicoveryDevice: Equatable {

    // MARK: Properties

    /// The advertised name derived from the advertisement data.
    public var localName: String? {
        return advertisementData[CBAdvertisementDataLocalNameKey] as? String
    }

    /// The data advertised while the discovery was made.
    public let advertisementData: [String: Any]

    /// The remote peripheral that was discovered.
    public let remotePeripheral: BleDevice

    /// The [RSSI (Received signal strength indication)](https://en.wikipedia.org/wiki/Received_signal_strength_indication) value when the discovery was made.
    public let RSSI: Int
    
    public let macAddress: String
    
    public let deviceId: String
    // MARK: Initialization

    public init(advertisementData: [String: Any], remotePeripheral: BleDevice, RSSI: Int, macAddress:String) {
        self.advertisementData = advertisementData
        self.remotePeripheral = remotePeripheral
        self.RSSI = RSSI
        self.macAddress = macAddress
        self.deviceId = remotePeripheral.identifier.uuidString
    }

}
