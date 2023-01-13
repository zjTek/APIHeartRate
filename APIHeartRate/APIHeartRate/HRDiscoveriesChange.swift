
import Foundation

public func == (lhs: HRDiscoveriesChange, rhs: HRDiscoveriesChange) -> Bool {
    switch (lhs, rhs) {
    case (.insert(let lhsDiscovery), .insert(let rhsDiscovery)):
        return lhsDiscovery == rhsDiscovery || lhsDiscovery == nil || rhsDiscovery == nil
    case (.remove(let lhsDiscovery), .remove(let rhsDiscovery)):
        return lhsDiscovery == rhsDiscovery || lhsDiscovery == nil || rhsDiscovery == nil
    default:
        return false
    }
}

/**
    Change in available discoveries.
    - Insert: A new discovery.
    - Remove: A discovery has become unavailable.

    Cases without associated discoveries can be used to validate whether or not a change is and insert or a remove.
*/
public enum HRDiscoveriesChange: Equatable {

    case insert(discovery: BleDicoveryDevice?)
    case remove(discovery: BleDicoveryDevice?)

    /// The discovery associated with the change.
    public var discovery: BleDicoveryDevice! {
        switch self {
        case .insert(let discovery):
            return discovery
        case .remove(let discovery):
            return discovery
        }
    }

}
