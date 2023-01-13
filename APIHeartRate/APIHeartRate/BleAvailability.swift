
import Foundation
import CoreBluetooth

public func == (lhs: BleAvailability, rhs: BleAvailability) -> Bool {
    switch (lhs, rhs) {
    case (.available, .available):
        return true
    case (.unavailable(cause: .any), .unavailable):
        return true
    case (.unavailable, .unavailable(cause: .any)):
        return true
    case (.unavailable(let lhsCause), .unavailable(let rhsCause)):
        return lhsCause == rhsCause
    default:
        return false
    }
}

/**
    Bluetooth LE availability.
    - Available: Bluetooth LE is available.
    - Unavailable: Bluetooth LE is unavailable.

    The unavailable case can be accompanied by a cause.
*/
public enum BleAvailability: Equatable {

    case available
    case unavailable(cause: BleUnavailabilityCause)

    @available(iOS 10.0, *)
    internal init(managerState: CBManagerState) {
        switch managerState {
        case .poweredOn: self = .available
        default: self = .unavailable(cause: BleUnavailabilityCause(managerState: managerState))
        }
    }
}

/**
    Bluetooth LE unavailability cause.
    - Any: When initialized with nil.
    - Resetting: Bluetooth is resetting.
    - Unsupported: Bluetooth LE is not supported on the device.
    - Unauthorized: The app isn't allowed to use Bluetooth.
    - PoweredOff: Bluetooth is turned off.
*/
public enum BleUnavailabilityCause: ExpressibleByNilLiteral {

    case any
    case resetting
    case unsupported
    case unauthorized
    case poweredOff

    public init(nilLiteral: Void) {
        self = .any
    }

    @available(iOS 10.0, *)
    internal init(managerState: CBManagerState) {
        switch managerState {
        case .poweredOff: self = .poweredOff
        case .resetting: self = .resetting
        case .unauthorized: self = .unauthorized
        case .unsupported: self = .unsupported
        default: self = nil
        }
    }
}

/**
    Classes that can be observed for Bluetooth LE availability implement this protocol.
*/
public protocol HRAvailabilityObservable: AnyObject {
    var availabilityObservers: [HRWeakAvailabilityObserver] { get set }
    func addAvailabilityObserver(_ availabilityObserver: HRAvailabilityObserver)
    func removeAvailabilityObserver(_ availabilityObserver: HRAvailabilityObserver)
}

/**
    Class used to hold a weak reference to an observer of Bluetooth LE availability.
*/
public class HRWeakAvailabilityObserver {
    weak var availabilityObserver: HRAvailabilityObserver?
    init (availabilityObserver: HRAvailabilityObserver) {
        self.availabilityObserver = availabilityObserver
    }
}

public extension HRAvailabilityObservable {

    /**
        Add a new availability observer. The observer will be weakly stored. If the observer is already subscribed the call will be ignored.
        - parameter availabilityObserver: The availability observer to add.
    */
    func addAvailabilityObserver(_ availabilityObserver: HRAvailabilityObserver) {
        if !availabilityObservers.contains(where: { $0.availabilityObserver === availabilityObserver }) {
            availabilityObservers.append(HRWeakAvailabilityObserver(availabilityObserver: availabilityObserver))
        }
    }

    /**
        Remove an availability observer. If the observer isn't subscribed the call will be ignored.
        - parameter availabilityObserver: The availability observer to remove.
    */
    func removeAvailabilityObserver(_ availabilityObserver: HRAvailabilityObserver) {
        if availabilityObservers.contains(where: { $0.availabilityObserver === availabilityObserver }) {
            availabilityObservers.remove(at: availabilityObservers.firstIndex(where: { $0 === availabilityObserver })!)
        }
    }

}

/**
    Observers of Bluetooth LE availability should implement this protocol.
*/
public protocol HRAvailabilityObserver: AnyObject {

    /**
        Informs the observer about a change in Bluetooth LE availability.
        - parameter availabilityObservable: The object that registered the availability change.
        - parameter availability: The new availability value.
    */
    func availabilityObserver(_ availabilityObservable: HRAvailabilityObservable, availabilityDidChange availability: BleAvailability)

    /**
        Informs the observer that the cause of Bluetooth LE unavailability changed.
        - parameter availabilityObservable: The object that registered the cause change.
        - parameter unavailabilityCause: The new cause of unavailability.
    */
    func availabilityObserver(_ availabilityObservable: HRAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BleUnavailabilityCause)
}
