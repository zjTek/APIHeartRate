
import Foundation

internal class HRContinousScanner {

    // MARK: Type Aliases

    internal typealias ErrorHandler = ((_ error: HRError) -> Void)
    internal typealias StateHandler = HRCentral.ContinuousScanStateHandler
    internal typealias ChangeHandler = HRCentral.ContinuousScanChangeHandler

    // MARK: Enums

    internal enum HRError: Error {
        case busy
        case interrupted
        case internalError(underlyingError: Error)
    }

    // MARK: Properties

    internal var state: HRCentral.ContinuousScanState
    private let scanner: HRScanner
    private var busy = false
    private var maintainedDiscoveries = [BleDicoveryDevice]()
    private var inBetweenDelayTimer: Timer?
    private var errorHandler: ErrorHandler?
    private var stateHandler: StateHandler?
    private var changeHandler: ChangeHandler?
    private var duration: TimeInterval!
    private var inBetweenDelay: TimeInterval!
    private var updateDuplicates: Bool!

    // MARK: Initialization

    internal init(scanner: HRScanner) {
        self.scanner = scanner
        state = .stopped
    }

    // MARK: Internal Functions

    internal func scanContinuouslyWithChangeHandler(_ changeHandler: @escaping ChangeHandler, stateHandler: StateHandler? = nil, duration: TimeInterval = 3, inBetweenDelay: TimeInterval = 3, updateDuplicates: Bool, errorHandler: ErrorHandler?) {
        guard !busy else {
            errorHandler?(.busy)
            return
        }
        busy = true
        self.duration = duration
        self.inBetweenDelay = inBetweenDelay
        self.updateDuplicates = updateDuplicates
        self.errorHandler = errorHandler
        self.stateHandler = stateHandler
        self.changeHandler = changeHandler
        scan()
    }

    internal func interruptScan() {
        scanner.interruptScan()
        endScanning(.interrupted)
    }

    // MARK: Private Functions

    private func scan() {
        do {
            state = .scanning
            stateHandler?(state)
            try scanner.scanWithDuration(duration, updateDuplicates: self.updateDuplicates, progressHandler: { newDiscoveries in
                var changes: [HRDiscoveriesChange] = []

                //find discoveries that have been updated and add a change for each
                for newDiscovery in newDiscoveries {
                    if let index = self.maintainedDiscoveries.firstIndex(of: newDiscovery) {
                        let outdatedDiscovery = self.maintainedDiscoveries[index]
                        self.maintainedDiscoveries[index] = newDiscovery

                        //TODO: probably need an update change
                        changes.append(.remove(discovery: outdatedDiscovery))
                        changes.append(.insert(discovery: newDiscovery))
                    } else if !self.maintainedDiscoveries.contains(newDiscovery) {

                        self.maintainedDiscoveries.append(newDiscovery)
                        changes.append(.insert(discovery: newDiscovery))
                    }
                }

                if !changes.isEmpty {
                    self.changeHandler?(changes, self.maintainedDiscoveries)
                }
            }, completionHandler: { result, error in
                guard result != nil && error == nil else {
                    self.endScanning(HRError.internalError(underlyingError: error! as Error))
                    return
                }
                let discoveriesToRemove = self.maintainedDiscoveries.filter({ !result!.contains($0) })
                let changes = discoveriesToRemove.map({ HRDiscoveriesChange.remove(discovery: $0) })
                for discoveryToRemove in discoveriesToRemove {
                    self.maintainedDiscoveries.remove(at: self.maintainedDiscoveries.firstIndex(of: discoveryToRemove)!)
                }
                self.changeHandler?(changes, self.maintainedDiscoveries)
                self.state = .waiting
                self.stateHandler?(self.state)
                self.inBetweenDelayTimer = Timer.scheduledTimer(timeInterval: self.inBetweenDelay, target: self, selector: #selector(HRContinousScanner.inBetweenDelayTimerElapsed), userInfo: nil, repeats: false)
            })
        } catch let error {
            endScanning(HRError.internalError(underlyingError: error))
        }
    }

    private func reset() {
        inBetweenDelayTimer?.invalidate()
        maintainedDiscoveries.removeAll()
        errorHandler = nil
        stateHandler = nil
        changeHandler = nil
    }

    private func endScanning(_ error: HRError?) {
        busy = false
        state = .stopped
        let errorHandler = self.errorHandler
        let stateHandler = self.stateHandler
        reset()
        stateHandler?(state)
        if let error = error {
            errorHandler?(error)
        }
    }

    @objc private func inBetweenDelayTimerElapsed() {
        scan()
    }

}
