
import Foundation
import CoreBluetooth

/**
    Class that represents a configuration used when starting a HRCentral object.
*/
public class HRConfiguration {

    
    /// The UUID for the service used to send data. This should be unique to your applications.
    public let serviceCBUUIDs: [CBUUID]
    
    internal var serviceUUIDs: [CBUUID]? {
        return serviceCBUUIDs
    }

    // MARK: Initialization

    public init(dataServiceUUIDs: [CBUUID]) {
        self.serviceCBUUIDs = dataServiceUUIDs
    }
    
    

}
