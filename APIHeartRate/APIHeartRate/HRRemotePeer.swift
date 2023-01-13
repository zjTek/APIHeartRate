
import Foundation
import CoreBluetooth

public protocol HRRemotePeerDelegate: AnyObject {
    /**
     Called when the remote peer sent data.
     - parameter remotePeripheral: The remote peripheral that sent the data.
     - parameter data: The data it sent.
     */
    func remotePeer(characteristic: CBCharacteristic,_ remotePeer: HRRemotePeer, didSendArbitraryData data: Data)
}

public func == (lhs: HRRemotePeer, rhs: HRRemotePeer) -> Bool {
    return (lhs.identifier == rhs.identifier)
}

public class HRRemotePeer: Equatable {

    /// A unique identifier for the peer, derived from the underlying CBCentral or CBPeripheral object, or set manually.
    public let identifier: UUID
    public let deviceId: String
    public weak var delegate: HRRemotePeerDelegate?

    private var data: Data?

    init(identifier: UUID) {
        self.identifier = identifier
        self.deviceId = identifier.uuidString
    }

    internal var maximumUpdateValueLength: Int {
        return 20
    }

    internal func handleReceivedData(characteristic: CBCharacteristic,_ receivedData: Data) {
            delegate?.remotePeer(characteristic: characteristic,self, didSendArbitraryData: receivedData)
    }

}
