
import Foundation
import CoreBluetooth

/**
    A subclass of HRConfiguration for constructing configurations to use when starting HRPeripheral objects.
*/
public class HRPeripheralConfiguration: HRConfiguration {

    // MARK: Properties

    /// The local name to broadcast to remote centrals.
    public let localName: String?

    // MARK: Initialization

    public init(dataServiceUUID: UUID,localName: String? = nil) {
        self.localName = localName
        super.init(dataServiceUUIDs: [])
    }

}
