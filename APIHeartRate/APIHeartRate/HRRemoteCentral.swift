
import Foundation
import CoreBluetooth

/**
    Representation of a remote central.
*/
public class HRRemoteCentral: HRRemotePeer {

    // MARK: Properties

    internal let central: CBCentral

    override internal var maximumUpdateValueLength: Int {
        return central.maximumUpdateValueLength
    }

    // MARK: Initialization

    internal init(central: CBCentral) {
        self.central = central
        super.init(identifier: central.identifier)
    }

}
