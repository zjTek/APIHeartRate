
import Foundation

internal func == (lhs: HRSendDataTask, rhs: HRSendDataTask) -> Bool {
    return lhs.destination == rhs.destination && lhs.data == rhs.data
}

internal class HRSendDataTask: Equatable {

    // MARK: Properties

    internal let data: Data
    internal let destination: HRRemotePeer
    internal let completionHandler: HRSendDataCompletionHandler?
    internal var offset = 0

    internal var maximumPayloadLength: Int {
        return destination.maximumUpdateValueLength
    }

    internal var lengthOfRemainingData: Int {
        return data.count - offset
    }

    internal var sentAllData: Bool {
        return lengthOfRemainingData == 0
    }

    internal var rangeForNextPayload: Range<Int>? {
        let lenghtOfNextPayload = maximumPayloadLength <= lengthOfRemainingData ? maximumPayloadLength : lengthOfRemainingData
        let payLoadRange = NSRange(location: offset, length: lenghtOfNextPayload)
        return Range(payLoadRange)
    }

    internal var nextPayload: Data? {
        if let range = rangeForNextPayload {
             return data.subdata(in: range)
        } else {
            return nil
        }
    }

    // MARK: Initialization

    internal init(data: Data, destination: HRRemotePeer, completionHandler: HRSendDataCompletionHandler?) {
        self.data = data
        self.destination = destination
        self.completionHandler = completionHandler
    }

}
