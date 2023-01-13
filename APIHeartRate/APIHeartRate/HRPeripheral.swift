
import Foundation
import CoreBluetooth

/**
    The peripheral's delegate is called when asynchronous events occur.
*/

public protocol HRPeripheralDelegate: AnyObject {
    /**
        Called when a remote central connects and is ready to receive data.
        - parameter peripheral: The peripheral object to which the remote central connected.
        - parameter remoteCentral: The remote central that connected.
    */
    func peripheral(_ peripheral: HRPeripheral, remoteCentralDidConnect remoteCentral: HRRemoteCentral)
    /**
        Called when a remote central disconnects and can no longer receive data.
        - parameter peripheral: The peripheral object from which the remote central disconnected.
        - parameter remoteCentral: The remote central that disconnected.
    */
    func peripheral(_ peripheral: HRPeripheral, remoteCentralDidDisconnect remoteCentral: HRRemoteCentral)
}

/**
    The class used to take the Bluetooth LE peripheral role. Peripherals can be discovered and connected to by centrals.
    One a central has connected, the peripheral can send data to it.
*/

public class  HRPeripheral: HRPeer, HRCBPeripheralManagerDelegate, HRAvailabilityObservable {

    // MARK: Properies

    /// Bluetooth LE availability derived from the underlying CBPeripheralManager object.

    public var availability: BleAvailability {
        return BleAvailability(managerState: peripheralManager.state)
    }

    /// The configuration that the HRPeripheral object was started with.
    override public var configuration: HRPeripheralConfiguration? {
        return _configuration
    }

    /// The HRPeriheral object's delegate.
    public weak var delegate: HRPeripheralDelegate?

    /// Current availability observers
    public var availabilityObservers = [HRWeakAvailabilityObserver]()

    /// Currently connected remote centrals
    public var connectedRemoteCentrals: [HRRemoteCentral] {
        return connectedRemotePeers.compactMap({
            $0 as? HRRemoteCentral
        })
    }

    private var _configuration: HRPeripheralConfiguration!
    private var peripheralManager: CBPeripheralManager!
    private let stateMachine = HRPeripheralStateMachine()
    private var peripheralManagerDelegateProxy: HRCBPeripheralManagerDelegateProxy!
    private var characteristicData: CBMutableCharacteristic!
    private var dataService: CBMutableService!

    // MARK: Initialization

    public override init() {
        super.init()
        peripheralManagerDelegateProxy = HRCBPeripheralManagerDelegateProxy(delegate: self)
    }

    // MARK: Public Functions

    /**
        Starts the HRPeripheral object. Once started the peripheral will be discoverable and possible to connect to
        by remote centrals, provided that Bluetooth LE is available.
        - parameter configuration: A configuration defining the unique identifiers along with the name to be broadcasted.
        - throws: An internal error if the HRPeripheral object was already started.
    */
    public func startWithConfiguration(_ configuration: HRPeripheralConfiguration) throws {
        do {
            try stateMachine.handleEvent(event: .start)
            _configuration = configuration
            peripheralManager = CBPeripheralManager(delegate: peripheralManagerDelegateProxy, queue: nil, options: nil)
        } catch let error {
            throw BleCommonError.internalError(underlyingError: error)
        }
    }

    /**
        Stops the HRPeripheral object.
        - throws: An internal error if the peripheral object wasn't started.
    */
    public func stop() throws {
        do {
            try stateMachine.handleEvent(event: .stop)
            _configuration = nil
            if peripheralManager.isAdvertising {
                peripheralManager.stopAdvertising()
            }
            peripheralManager.removeAllServices()
            peripheralManager = nil
        } catch let error {
            throw BleCommonError.internalError(underlyingError: error)
        }
    }

    // MARK: Private Functions

    private func setUnavailable(_ cause: BleUnavailabilityCause, oldCause: BleUnavailabilityCause?) {
        if oldCause == nil {
            for remotePeer in connectedRemotePeers {
                if let remoteCentral = remotePeer as? HRRemoteCentral {
                    handleDisconnectForRemoteCentral(remoteCentral)
                }
            }
            for availabilityObserver in availabilityObservers {
                availabilityObserver.availabilityObserver?.availabilityObserver(self, availabilityDidChange: .unavailable(cause: cause))
            }
        } else if oldCause != nil && oldCause != cause {
            for availabilityObserver in availabilityObservers {
                availabilityObserver.availabilityObserver?.availabilityObserver(self, unavailabilityCauseDidChange: cause)
            }
        }
    }

    private func setAvailable() {
        for availabilityObserver in availabilityObservers {
            availabilityObserver.availabilityObserver?.availabilityObserver(self, availabilityDidChange: .available)
        }
        if !peripheralManager.isAdvertising {
            dataService = CBMutableService(type: HRServiceConst.customServiveID, primary: true)
            let properties: CBCharacteristicProperties = [ .read, .notify, .writeWithoutResponse, .write ]
            let permissions: CBAttributePermissions = [ .readable, .writeable ]
            characteristicData = CBMutableCharacteristic(type: HRServiceConst.writeCharacteristic, properties: properties, value: nil, permissions: permissions)
            dataService.characteristics = [ characteristicData ]
            peripheralManager.add(dataService)
        }
    }

    internal override func sendData(_ data: Data, toRemotePeer remotePeer: HRRemotePeer) -> Bool {
        guard let remoteCentral = remotePeer as? HRRemoteCentral else {
            return false
        }
        return peripheralManager.updateValue(data, for: characteristicData, onSubscribedCentrals: [ remoteCentral.central ])
    }

    private func handleDisconnectForRemoteCentral(_ remoteCentral: HRRemoteCentral) {
        failSendDataTasksForRemotePeer(remoteCentral)
        connectedRemotePeers.remove(at: connectedRemotePeers.firstIndex(of: remoteCentral)!)
        delegate?.peripheral(self, remoteCentralDidDisconnect: remoteCentral)
    }

    // MARK: HRCBPeripheralManagerDelegate

    internal func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown, .resetting:
            break
        case .unsupported, .unauthorized, .poweredOff:
            let newCause = BleUnavailabilityCause(managerState: peripheralManager.state)

            switch stateMachine.state {
            case let .unavailable(cause):
                let oldCause = cause
                _ = try? stateMachine.handleEvent(event: .setUnavailable(cause: newCause))
                setUnavailable(oldCause, oldCause: newCause)
            default:
                _ = try? stateMachine.handleEvent(event: .setUnavailable(cause: newCause))
                setUnavailable(newCause, oldCause: nil)
            }
        case .poweredOn:
            let state = stateMachine.state
            _ = try? stateMachine.handleEvent(event: .setAvailable)
            switch state {
            case .starting, .unavailable:
                setAvailable()
            default:
                break
            }
        @unknown default:
            break
        }
    }

    internal func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {

    }

    internal func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if !peripheralManager.isAdvertising {
            var advertisementData: [String: Any] = [ CBAdvertisementDataServiceUUIDsKey: _configuration.serviceUUIDs as Any ]
            if let localName = _configuration.localName {
                advertisementData[CBAdvertisementDataLocalNameKey] = localName
            }
            peripheralManager.startAdvertising(advertisementData)
        }
    }

    internal func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        let remoteCentral = HRRemoteCentral(central: central)
        connectedRemotePeers.append(remoteCentral)
        delegate?.peripheral(self, remoteCentralDidConnect: remoteCentral)
    }

    internal func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        if let remoteCentral = connectedRemotePeers.filter({ ($0.identifier == central.identifier) }).last as? HRRemoteCentral {
            handleDisconnectForRemoteCentral(remoteCentral)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for writeRequest in requests {
            guard writeRequest.characteristic.uuid == characteristicData.uuid else {
                continue
            }
            guard let remotePeer = (connectedRemotePeers.filter { $0.identifier == writeRequest.central.identifier } .last),
                  let remoteCentral = remotePeer as? HRRemoteCentral,
                  let data = writeRequest.value else {
                continue
            }
            remoteCentral.handleReceivedData(characteristic: writeRequest.characteristic, data)
        }
    }

    internal func peripheralManagerIsReadyToUpdateSubscribers(_ peripheral: CBPeripheralManager) {
        processSendDataTasks()
    }

}
