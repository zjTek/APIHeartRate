
import Foundation

internal class HRCentralStateMachine {

    // MARK: Enums

    internal enum HRError: Error {
        case transitioning(currentState: State, validStates: [State])
    }

    internal enum State {
        case initialized, starting, unavailable(cause: BleUnavailabilityCause), available, scanning
    }

    internal enum Event {
        case start, setUnavailable(cause: BleUnavailabilityCause), setAvailable, scan, connect, stop
    }

    // MARK: Properties

    internal var state: State

    // MARK: Initialization

    internal init() {
        self.state = .initialized
    }

    // MARK: Functions

    internal func handleEvent(_ event: Event) throws {
        switch event {
        case .start:
            try handleStartEvent(event)
        case .setAvailable:
            try handleSetAvailableEvent(event)
        case let .setUnavailable(newCause):
            try handleSetUnavailableEvent(event, cause: newCause)
        case .scan:
            try handleScanEvent(event)
        case .connect:
            try handleConnectEvent(event)
        case .stop:
            try handleStopEvent(event)
        }
    }

    private func handleStartEvent(_ event: Event) throws {
        switch state {
        case .initialized:
            state = .starting
        default:
            throw HRError.transitioning(currentState: state, validStates: [ .initialized ])
        }
    }

    private func handleSetAvailableEvent(_ event: Event) throws {
        switch state {
        case .initialized:
            throw HRError.transitioning(currentState: state, validStates: [ .starting, .available, .unavailable(cause: nil) ])
        default:
            state = .available
        }
    }

    private func handleSetUnavailableEvent(_ event: Event, cause: BleUnavailabilityCause) throws {
        switch state {
        case .initialized:
            throw HRError.transitioning(currentState: state, validStates: [ .starting, .available, .unavailable(cause: nil) ])
        default:
            state = .unavailable(cause: cause)
        }
    }

    private func handleScanEvent(_ event: Event) throws {
        switch state {
        case .available:
            state = .scanning
        default:
            throw HRError.transitioning(currentState: state, validStates: [ .available ])
        }
    }

    private func handleConnectEvent(_ event: Event) throws {
        switch state {
        case .available, .scanning:
            break
        default:
            throw HRError.transitioning(currentState: state, validStates: [ .available, .scanning ])
        }
    }

    private func handleStopEvent(_ event: Event) throws {
        switch state {
        case .initialized:
            throw HRError.transitioning(currentState: state, validStates: [ .starting, .unavailable(cause: nil), .available, .scanning ])
        default:
            state = .initialized
        }
    }

}
