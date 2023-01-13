
import Foundation

public typealias HRSendDataCompletionHandler = ((_ data: Data, _ remotePeer: HRRemotePeer, _ error: BleCommonError?) -> Void)

public class HRPeer {
    

    /// The configuration the BKCentral object was started with.
    public var configuration: HRConfiguration? {
        return nil
    }

    internal var connectedRemotePeers: [HRRemotePeer] {
        get {
            return _connectedRemotePeers
        }
        set {
            _connectedRemotePeers = newValue
        }
    }

    internal var sendDataTasks: [HRSendDataTask] = []

    private var _connectedRemotePeers: [HRRemotePeer] = []

    /**
     Sends data to a connected remote central.
     - parameter data: The data to send.
     - parameter remotePeer: The destination of the data payload.
     - parameter completionHandler: A completion handler allowing you to react in case the data failed to send or once it was sent succesfully.
     */
    public func sendData(_ data: Data, toRemotePeer remotePeer: HRRemotePeer, completionHandler: HRSendDataCompletionHandler?) {
        guard connectedRemotePeers.contains(remotePeer) else {
            completionHandler?(data, remotePeer, BleCommonError.devieNotConnected)
            return
        }
        let sendDataTask = HRSendDataTask(data: data, destination: remotePeer, completionHandler: completionHandler)
        sendDataTasks.append(sendDataTask)
        if sendDataTasks.count >= 1 {
            processSendDataTasks()
        }
    }

    internal func processSendDataTasks() {
        guard sendDataTasks.count > 0 else {
            return
        }
        let nextTask = sendDataTasks.first!
        if nextTask.sentAllData {
            sendDataTasks.remove(at: sendDataTasks.firstIndex(of: nextTask)!)
            nextTask.completionHandler?(nextTask.data, nextTask.destination, nil)
            processSendDataTasks()
        }
        if let nextPayload = nextTask.nextPayload {
            let sentNextPayload = sendData(nextPayload, toRemotePeer: nextTask.destination)
            if sentNextPayload {
                nextTask.offset += nextPayload.count
                processSendDataTasks()
            } else {
                return
            }
        } else {
            return
        }

    }

    internal func failSendDataTasksForRemotePeer(_ remotePeer: HRRemotePeer) {
        for sendDataTask in sendDataTasks.filter({ $0.destination == remotePeer }) {
            sendDataTasks.remove(at: sendDataTasks.firstIndex(of: sendDataTask)!)
            sendDataTask.completionHandler?(sendDataTask.data, sendDataTask.destination, .devieNotConnected)
        }
    }

    internal func sendData(_ data: Data, toRemotePeer remotePeer: HRRemotePeer) -> Bool {
        fatalError("Function must be overridden by subclass")
    }
    
}
