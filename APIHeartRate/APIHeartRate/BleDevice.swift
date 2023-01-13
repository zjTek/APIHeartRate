import CoreBluetooth
import Foundation

/**
 The delegate of a remote peripheral receives callbacks when asynchronous events occur.
 */
public protocol HRRemotePeripheralDelegate: AnyObject {
    /**
         Called when the remote peripheral updated its name.
         - parameter remotePeripheral: The remote peripheral that updated its name.
         - parameter name: The new name.
     */
    func remotePeripheral(_ remotePeripheral: BleDevice, didUpdateName name: String)

    /**
     Called when services and charateristic are discovered and the device is ready for send/receive
     - parameter remotePeripheral: The remote peripheral that is ready.
     */
    func remotePeripheralIsReady(_ remotePeripheral: BleDevice)
}

/**
 Class to represent a remote peripheral that can be connected to by HRCentral objects.
 */
public class BleDevice: HRRemotePeer, HRCBPeripheralDelegate {
    // MARK: Enums

    public enum ReadType {
        case battery, manufacturer, model, hardware, firmware, software, sysid,mac
    }

    /**
     Possible states for HRRemotePeripheral objects.
     - Shallow: The peripheral was initialized only with an identifier (used when one wants to connect to a peripheral for which the identifier is known in advance).
     - Disconnected: The peripheral is disconnected.
     - Connecting: The peripheral is currently connecting.
     - Connected: The peripheral is already connected.
     - Disconnecting: The peripheral is currently disconnecting.
     */
    public enum State {
        case shallow, disconnected, connecting, connected, disconnecting
    }

    // MARK: Properties

    /// The current state of the remote peripheral, either shallow or derived from an underlying CBPeripheral object.
    public var state: State {
        if peripheral == nil {
            return .shallow
        }
        switch peripheral!.state {
        case .disconnected:
            return .disconnected
        case .connecting:
            return .connecting
        case .connected:
            return .connected
        case .disconnecting:
            return .disconnecting
        @unknown default:
            return .shallow
        }
    }

    /// The name of the remote peripheral, derived from an underlying CBPeripheral object.
    public var name: String? {
        return peripheral?.name
    }
    
    public var macAddress:String = ""

    /// The remote peripheral's delegate.
    public weak var peripheralDelegate: HRRemotePeripheralDelegate?

    override internal var maximumUpdateValueLength: Int {
        guard #available(iOS 9, *), let peripheral = peripheral else {
            return super.maximumUpdateValueLength
        }
        #if os(OSX)
            return super.maximumUpdateValueLength
        #else
            return peripheral.maximumWriteValueLength(for: .withoutResponse)
        #endif
    }

    internal var peripheral: CBPeripheral?
    internal var macCharacteristic: CBCharacteristic?
    internal var batteryCharacteristic: CBCharacteristic?
    internal var manufacturerCharacteristic: CBCharacteristic?
    internal var modelCharacteristic: CBCharacteristic?
    internal var hardwareCharacteristic: CBCharacteristic?
    internal var firmwareCharacteristic: CBCharacteristic?
    internal var softwareCharacteristic: CBCharacteristic?
    internal var systemCharacteristic: CBCharacteristic?
    internal var heartReadCharacteristic: CBCharacteristic?
    internal var heartNotifyCharacteristic: CBCharacteristic?
    
    internal var writeCharacteristic: CBCharacteristic?
    internal var notifyCharacteristic: CBCharacteristic?

    private var peripheralDelegateProxy: HRCBPeripheralDelegateProxy!

    // MARK: Initialization

    public init(identifier: UUID, peripheral: CBPeripheral?) {
        super.init(identifier: identifier)
        peripheralDelegateProxy = HRCBPeripheralDelegateProxy(delegate: self)
        self.peripheral = peripheral
    }

    // MARK: Internal Functions

    internal func prepareForConnection() {
        peripheral?.delegate = peripheralDelegateProxy
    }

    internal func discoverServices() {
        if peripheral?.services != nil {
            peripheral(peripheral!, didDiscoverServices: nil)
            return
        }
        peripheral?.discoverServices(nil)
    }

    internal func unsubscribe() {
        guard peripheral?.services != nil else {
            return
        }
        for service in peripheral!.services! {
            guard service.characteristics != nil else {
                continue
            }
            for characteristic in service.characteristics! {
                peripheral?.setNotifyValue(false, for: characteristic)
            }
        }
    }

    // MARK: HRCBPeripheralDelegate

    internal func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        peripheralDelegate?.remotePeripheral(self, didUpdateName: name!)
    }

    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            if service.characteristics != nil {
                self.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: nil)
            } else {
                peripheral.discoverCharacteristics(HRServiceConst.characteristicUUIDsForServiceUUID(service.uuid), for: service)
            }
        }
    }

    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        getCharacteristic(service: service)
    }

    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        handleReceivedData(characteristic: characteristic, characteristic.value!)
    }

    internal func mapReadCharacteristic(type: ReadType) -> CBCharacteristic? {
        switch type {
        case .mac:
            return macCharacteristic
        case .battery:
            return batteryCharacteristic
        case .manufacturer:
            return manufacturerCharacteristic
        case .hardware:
            return hardwareCharacteristic
        case .firmware:
            return firmwareCharacteristic
        case .software:
            return softwareCharacteristic
        case .sysid:
            return systemCharacteristic
        case .model:
            return modelCharacteristic
        }
    }
    
    internal func mapReadCharacteristic(uuid: CBUUID) -> CBCharacteristic? {
        switch uuid {
        case HRServiceConst.macCharacteristic:
            return macCharacteristic
        case HRServiceConst.batteryCharacteristic:
            return batteryCharacteristic
        case HRServiceConst.manuCharacteristic:
            return manufacturerCharacteristic
        case HRServiceConst.hardwareCharacteristic:
            return hardwareCharacteristic
        case HRServiceConst.firmwareCharacteristic:
            return firmwareCharacteristic
        case HRServiceConst.softwareCharacteristic:
            return softwareCharacteristic
        case HRServiceConst.sysIDCharacteristic:
            return systemCharacteristic
        case HRServiceConst.modelCharacteristic:
            return modelCharacteristic
        default:
            return nil
        }
    }

    internal func getCharacteristic(service: CBService) {
        if service.uuid == HRServiceConst.batteryServiveID {
            guard let batteryChar = service.characteristics?.first else { return }
            batteryCharacteristic = batteryChar
        } else if service.uuid == HRServiceConst.macServiveID {
            guard let macChar = service.characteristics?.first else { return }
            macCharacteristic = macChar
        } else if service.uuid == HRServiceConst.generalServiveID {
            if let chars = service.characteristics {
                for char in chars {
                    if char.uuid == HRServiceConst.manuCharacteristic {
                        manufacturerCharacteristic = char
                    } else if char.uuid == HRServiceConst.modelCharacteristic {
                        modelCharacteristic = char
                    } else if char.uuid == HRServiceConst.hardwareCharacteristic {
                        hardwareCharacteristic = char
                    } else if char.uuid == HRServiceConst.firmwareCharacteristic {
                        firmwareCharacteristic = char
                    } else if char.uuid == HRServiceConst.softwareCharacteristic {
                        softwareCharacteristic = char
                    } else if char.uuid == HRServiceConst.sysIDCharacteristic {
                        systemCharacteristic = char
                    }
                }
            }

        } else if service.uuid == HRServiceConst.heartRateServiveID {
            if let chars = service.characteristics {
                for char in chars {
                    if char.uuid == HRServiceConst.heartNotifyCharacteristic {
                        heartNotifyCharacteristic = char
                        peripheral?.setNotifyValue(true, for: char)
                    } else if char.uuid == HRServiceConst.heartReadCharacteristic {
                        heartReadCharacteristic = char
                    }
                }
            }
            
        } else if service.uuid == HRServiceConst.customServiveID {
            if let chars = service.characteristics {
                for char in chars {
                    if char.uuid == HRServiceConst.writeCharacteristic {
                        writeCharacteristic = char
                    } else if char.uuid == HRServiceConst.notifyCharacteristic {
                        notifyCharacteristic = char
                        peripheral?.setNotifyValue(true, for: char)
                        peripheralDelegate?.remotePeripheralIsReady(self)
                    }
                }
            }
        }
    }
}
