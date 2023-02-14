//
//  HRCentral.swift
//  APIHeartRate_Example
//
//  Created by Tek on 2023/1/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
    The central's delegate is called when asynchronous events occur.
*/
public protocol HRCentralDelegate: AnyObject {
    /**
        Called when a remote peripheral disconnects or is disconnected.
        - parameter central: The central from which it disconnected.
        - parameter remotePeripheral: The remote peripheral that disconnected.
    */

    func central(_ central: HRCentral, remotePeripheralDidDisconnect remotePeripheral: BleDevice)
}

/**
    The class used to take the Bluetooth LE central role. The central discovers remote peripherals by scanning
    and connects to them. When a connection is established the central can receive data from the remote peripheral.
*/

public class HRCentral: HRPeer, HRCBCentralManagerStateDelegate, HRConnectionPoolDelegate, HRAvailabilityObservable {

    // MARK: Type Aliases

    public typealias ScanProgressHandler = ((_ newDiscoveries: [BleDicoveryDevice]) -> Void)
    public typealias ScanCompletionHandler = ((_ result: [BleDicoveryDevice]?, _ error: BleConnectError?) -> Void)
    public typealias ContinuousScanChangeHandler = ((_ changes: [HRDiscoveriesChange], _ discoveries: [BleDicoveryDevice]) -> Void)
    public typealias ContinuousScanStateHandler = ((_ newState: ContinuousScanState) -> Void)
    public typealias ContinuousScanErrorHandler = ((_ error: BleConnectError) -> Void)
    public typealias ConnectCompletionHandler = ((_ remotePeripheral: BleDevice, _ error: BleConnectError?) -> Void)

    // MARK: Enums

    /**
        Possible states returned by the ContinuousScanStateHandler.
        - Stopped: The scan has come to a complete stop and won't start again by triggered manually.
        - Scanning: The scan is currently active.
        - Waiting: The scan is on hold due while waiting for the in-between delay to expire, after which it will start again.
    */
    public enum ContinuousScanState {
        case stopped
        case scanning
        case waiting
    }

    // MARK: Properties

    /// Bluetooth LE availability, derived from the underlying CBCentralManager.
    public var availability: BleAvailability? {
        guard let centralManager = _centralManager else {
            return nil
        }

        if #available(iOS 10.0, *) {
            return BleAvailability(managerState: centralManager.state)
        } else {
            // Fallback on earlier versions
        }
    }

    /// All currently connected remote peripherals.
    public var connectedRemotePeripherals: [BleDevice] {
        return connectionPool.connectedRemotePeripherals
    }


    /// The delegate of the HRCentral object.
    public weak var delegate: HRCentralDelegate?

    /// Current availability observers.
    public var availabilityObservers = [HRWeakAvailabilityObserver]()

    internal override var connectedRemotePeers: [HRRemotePeer] {
        get {
            return connectedRemotePeripherals
        }
        set {
            connectionPool.connectedRemotePeripherals = newValue.compactMap({
                return $0 as? BleDevice
            })
        }
    }

    private var centralManager: CBCentralManager? {
        return _centralManager
    }

    private let scanner = HRScanner()
    private let connectionPool = HRConnectionPool()
    private var _configuration: HRConfiguration?
    private var continuousScanner: HRContinousScanner!
    private var centralManagerDelegateProxy: HRCBCentralManagerDelegateProxy!
    private var stateMachine: HRCentralStateMachine!
    private var _centralManager: CBCentralManager!

    // MARK: Initialization

    public override init() {
        super.init()
        centralManagerDelegateProxy = HRCBCentralManagerDelegateProxy(stateDelegate: self, discoveryDelegate: scanner, connectionDelegate: connectionPool)
        stateMachine = HRCentralStateMachine()
        connectionPool.delegate = self
        continuousScanner = HRContinousScanner(scanner: scanner)
    }

    // MARK: Public Functions

    /**
        Start the HRCentral object with a configuration.
        - parameter configuration: The configuration defining which UUIDs to use when discovering peripherals.
        - throws: Throws an InternalError if the HRCentral object is already started.
    */
    public func startWithConfiguration() throws {
        do {
            try stateMachine.handleEvent(.start)
            
            _centralManager = CBCentralManager(delegate: centralManagerDelegateProxy, queue: nil, options: nil)
            scanner.centralManager = centralManager
            connectionPool.centralManager = centralManager
        } catch let error {
            throw BleCommonError.internalError(underlyingError: error)
        }
    }
    /**
        Scan for peripherals for a limited duration of time.
        - parameter duration: The number of seconds to scan for (defaults to 3). A duration of 0 means endless
        - parameter updateDuplicates: normally, discoveries for the same peripheral are coalesced by iOS. Setting this to true advises the OS to generate new discoveries anyway. This allows you to react to RSSI changes (defaults to false).
        - parameter progressHandler: A progress handler allowing you to react immediately when a peripheral is discovered during a scan.
        - parameter completionHandler: A completion handler allowing you to react on the full result of discovered peripherals or an error if one occured.
    */
    public func scanWithDuration(_ duration: TimeInterval = 0, updateDuplicates: Bool = false, progressHandler: ScanProgressHandler?, completionHandler: ScanCompletionHandler?) {
        do {
            try stateMachine.handleEvent(.scan)
            try scanner.scanWithDuration(duration, updateDuplicates: updateDuplicates, progressHandler: progressHandler) { result, error in
                var returnError: BleConnectError?
                if error == nil {
                    _ = try? self.stateMachine.handleEvent(.setAvailable)
                } else {
                    returnError = .internalError(underlyingError: error)
                }
                completionHandler?(result, returnError)
            }
        } catch let error {
            completionHandler?(nil, .internalError(underlyingError: error))
            return
        }
    }
    
    public func endScan() {
        scanner.endScan(.endByUser)
    }

    /**
        Scan for peripherals for a limited duration of time continuously with an in-between delay.
        - parameter changeHandler: A change handler allowing you to react to changes in "maintained" discovered peripherals.
        - parameter stateHandler: A state handler allowing you to react when the scanner is started, waiting and stopped.
        - parameter duration: The number of seconds to scan for (defaults to 3). A duration of 0 means endless and inBetweenDelay is pointless
        - parameter inBetweenDelay: The number of seconds to wait for, in-between scans (defaults to 3).
        - parameter updateDuplicates: normally, discoveries for the same peripheral are coalesced by IOS. Setting this to true advises the OS to generate new discoveries anyway. This allows you to react to RSSI changes (defaults to false).
        - parameter errorHandler: An error handler allowing you to react when an error occurs. For now this is also called when the scan is manually interrupted.
    */

    public func scanContinuouslyWithChangeHandler(_ changeHandler: @escaping ContinuousScanChangeHandler, stateHandler: ContinuousScanStateHandler?, duration: TimeInterval = 3, inBetweenDelay: TimeInterval = 3, updateDuplicates: Bool = false, errorHandler: ContinuousScanErrorHandler?) {
        do {
            try stateMachine.handleEvent(.scan)
            continuousScanner.scanContinuouslyWithChangeHandler(changeHandler, stateHandler: { newState in
                if newState == .stopped && self.availability == .available {
                    _ = try? self.stateMachine.handleEvent(.setAvailable)
                }
                stateHandler?(newState)
            }, duration: duration, inBetweenDelay: inBetweenDelay, updateDuplicates: updateDuplicates, errorHandler: { error in
                errorHandler?(.internalError(underlyingError: error))
            })
        } catch let error {
            errorHandler?(.internalError(underlyingError: error))
        }
    }

    /**
        Interrupts the active scan session if present.
    */
    public func interruptScan() {
        continuousScanner.interruptScan()
        scanner.interruptScan()
    }

    /**
        Connect to a remote peripheral.
        - parameter timeout: The number of seconds the connection attempt should continue for before failing.
        - parameter remotePeripheral: The remote peripheral to connect to.
        - parameter completionHandler: A completion handler allowing you to react when the connection attempt succeeded or failed.
    */
    public func connect(_ timeout: TimeInterval = 3, remotePeripheral: BleDevice, completionHandler: @escaping ConnectCompletionHandler) {
        do {
            try stateMachine.handleEvent(.connect)
            try connectionPool.connectWithTimeout(timeout, remotePeripheral: remotePeripheral) { remotePeripheral, error in
                var returnError: BleConnectError?
                if error == nil {
                    _ = try? self.stateMachine.handleEvent(.setAvailable)
                } else {
                    returnError = .internalError(underlyingError: error)
                }
                completionHandler(remotePeripheral, returnError)
            }
        } catch let error {
            completionHandler(remotePeripheral, .internalError(underlyingError: error))
            return
        }
    }

    /**
        Disconnects a connected peripheral.
        - parameter remotePeripheral: The peripheral to disconnect.
        - throws: Throws an InternalError if the remote peripheral is not currently connected.
    */
    public func disconnectRemotePeripheral(_ remotePeripheral: BleDevice) throws {
        do {
            try connectionPool.disconnectRemotePeripheral(remotePeripheral)
        } catch let error {
            throw BleConnectError.internalError(underlyingError: error)
        }
    }

    /**
        Stops the HRCentral object.
        - throws: Throws an InternalError if the HRCentral object isn't already started.
    */
    public func stop() throws {
        do {
            try stateMachine.handleEvent(.stop)
            interruptScan()
            connectionPool.reset()
            _configuration = nil
            _centralManager = nil
        } catch let error {
            throw BleConnectError.internalError(underlyingError: error)
        }
    }

    /**
        Retrieves a previously-scanned peripheral for direct connection.
        - parameter remoteUUID: The UUID of the remote peripheral to look for
        - return: optional remote peripheral if found
     */
    public func retrieveRemotePeripheralWithUUID (remoteUUID: UUID) -> BleDevice? {
        guard let peripherals = retrieveRemotePeripheralsWithUUIDs(remoteUUIDs: [remoteUUID]) else {
            return nil
        }
        guard peripherals.count > 0 else {
            return nil
        }
        return peripherals[0]
    }

    /**
        Retrieves an array of previously-scanned peripherals for direct connection.
        - parameter remoteUUIDs: An array of UUIDs of remote peripherals to look for
        - return: optional array of found remote peripherals
     */
    public func retrieveRemotePeripheralsWithUUIDs (remoteUUIDs: [UUID]) -> [BleDevice]? {
        if let centralManager = _centralManager {
            let peripherals = centralManager.retrievePeripherals(withIdentifiers: remoteUUIDs)
            guard peripherals.count > 0 else {
                return nil
            }

            var remotePeripherals: [BleDevice] = []

            for peripheral in peripherals {
                let remotePeripheral = BleDevice(identifier: peripheral.identifier, peripheral: peripheral)
                remotePeripheral.macAddress = (UserDefaults.standard.object(forKey: peripheral.identifier.uuidString) as? String) ?? ""
                remotePeripherals.append(remotePeripheral)
            }
            return remotePeripherals
        }
        return nil
    }

    // MARK: Internal Functions

    internal func setUnavailable(_ cause: BleUnavailabilityCause, oldCause: BleUnavailabilityCause?) {
        scanner.interruptScan()
        connectionPool.reset()
        if oldCause == nil {
            for availabilityObserver in availabilityObservers {
                availabilityObserver.availabilityObserver?.availabilityObserver(self, availabilityDidChange: .unavailable(cause: cause))
            }
        } else if oldCause != nil && oldCause != cause {
            for availabilityObserver in availabilityObservers {
                availabilityObserver.availabilityObserver?.availabilityObserver(self, unavailabilityCauseDidChange: cause)
            }
        }
    }

    internal override func sendData(_ data: Data, toRemotePeer remotePeer: HRRemotePeer) -> Bool {
        guard let remotePeripheral = remotePeer as? BleDevice,
                let peripheral = remotePeripheral.peripheral,
                let characteristic = remotePeripheral.writeCharacteristic else {
            return false
        }
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        return true
    }
    
    func readData(_ type: BleDevice.ReadType, toRemotePeer remotePeer: HRRemotePeer) -> Bool {
        guard let remotePeripheral = remotePeer as? BleDevice,
                let peripheral = remotePeripheral.peripheral,
                let characteristic = remotePeripheral.mapReadCharacteristic(type: type) else {
            return false
        }
        peripheral.readValue(for: characteristic)
        return true
    }
    
    func readChar(uuid: CBUUID,toRemotePeer remotePeer: HRRemotePeer) -> Bool {
        guard let remotePeripheral = remotePeer as? BleDevice,
                let peripheral = remotePeripheral.peripheral,
                let characteristic = remotePeripheral.mapReadCharacteristic(uuid: uuid) else {
            return false
        }
        peripheral.readValue(for: characteristic)
        return true
    }
    
    func setCharNotify(uuid: CBUUID, enable: Bool, toRemotePeer remotePeer: HRRemotePeer) -> Bool{
        guard let remotePeripheral = remotePeer as? BleDevice,
              let peripheral = remotePeripheral.peripheral,
        let notify = remotePeripheral.notifyCharacteristic,let heartNotify = remotePeripheral.heartNotifyCharacteristic else {
            return false
        }
        if (uuid == notify.uuid) {
            peripheral.setNotifyValue(enable, for: notify)
            return true
        } else if (uuid == heartNotify.uuid) {
            peripheral.setNotifyValue(enable, for: heartNotify)
            return true
        }
        return false
    }
    
    func writeChar(uuid: CBUUID, _ data: Data, toRemotePeer remotePeer: HRRemotePeer) -> Bool{
        guard let remotePeripheral = remotePeer as? BleDevice,
                let peripheral = remotePeripheral.peripheral,
                let characteristic = remotePeripheral.writeCharacteristic else {
            return false
        }
        if (uuid != characteristic) {
            return false
        }
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        return true
    }
    
    // MARK: HRCBCentralManagerStateDelegate

    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown, .resetting:
            break
        case .unsupported, .unauthorized, .poweredOff:
         
                let newCause = BleUnavailabilityCause(managerState: central.state)
   
            switch stateMachine.state {
            case let .unavailable(cause):
                let oldCause = cause
                _ = try? stateMachine.handleEvent(.setUnavailable(cause: newCause))
                setUnavailable(oldCause, oldCause: newCause)
            default:
                _ = try? stateMachine.handleEvent(.setUnavailable(cause: newCause))
                setUnavailable(newCause, oldCause: nil)
            }

        case .poweredOn:
            let state = stateMachine.state
            _ = try? stateMachine.handleEvent(.setAvailable)
            switch state {
            case .starting, .unavailable:
                for availabilityObserver in availabilityObservers {
                    availabilityObserver.availabilityObserver?.availabilityObserver(self, availabilityDidChange: .available)
                }
            default:
                break
            }
        @unknown default:
            break
        }
    }

    // MARK: HRConnectionPoolDelegate

    internal func connectionPool(_ connectionPool: HRConnectionPool, remotePeripheralDidDisconnect remotePeripheral: BleDevice) {
        delegate?.central(self, remotePeripheralDidDisconnect: remotePeripheral)
    }

}

