
import Foundation

/**
    Errors that can occur when interacting with BluetoothKit.
    - InterruptedByUnavailability(cause): Will be returned if Bluetooth ie. is turned off while performing an action.
    - FailedToConnectDueToTimeout: The time out elapsed while attempting to connect to a peripheral.
    - RemotePeerNotConnected: The action failed because the remote peer attempted to interact with, was not connected.
    - InternalError(underlyingError): Will be returned if any of the internal or private classes returns an unhandled error.
 */
public enum BleCommonError: Error {
    case internalError(underlyingError: Error?)
    case serviceNotFound
    case receivedEmptyData
    case receivedWrongData
    case deviceNotFound
    case devieNotConnected
}

public enum BleConnectError: Error {
    case deviceNotFound
    case deviceNotConnected
    case scanFailed
    case failedToDisconnect(underlyingError: Error?)
    case failedToConnectDueToTimeout
    case interruptedByUnavailability(cause: BleUnavailabilityCause)
    case internalError(underlyingError: Error?)
}
