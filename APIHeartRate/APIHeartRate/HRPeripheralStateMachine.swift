
import Foundation

internal class HRPeripheralStateMachine {

    // MARK: Enums

    internal enum BKError: Error {
        case transitioning(currentState: State, validStates: [State])
    }

    internal enum State {
        case initialized, starting, unavailable(cause: BleUnavailabilityCause), available
    }

    internal enum Event {
        case start, setUnavailable(cause: BleUnavailabilityCause), setAvailable, stop
    }

    // MARK: Properties

    internal var state: State

    // MARK: Initialization

    internal init() {
        self.state = .initialized
    }

    // MARK: Functions

    internal func handleEvent(event: Event) throws {
        switch event {
        case .start:
            try handleStartEvent(event: event)
        case .setAvailable:
            try handleSetAvailableEvent(event: event)
        case let .setUnavailable(cause):
            try handleSetUnavailableEvent(event: event, withCause: cause)
        case .stop:
            try handleStopEvent(event: event)
        }
    }

    private func handleStartEvent(event: Event) throws {
        switch state {
        case .initialized:
            state = .starting
        default:
            throw BKError.transitioning(currentState: state, validStates: [ .initialized ])
        }
    }

    private func handleSetAvailableEvent(event: Event) throws {
        switch state {
        case .initialized:
            throw BKError.transitioning(currentState: state, validStates: [ .starting, .available, .unavailable(cause: nil) ])
        default:
            state = .available
        }
    }

    private func handleSetUnavailableEvent(event: Event, withCause cause: BleUnavailabilityCause) throws {
        switch state {
        case .initialized:
            throw BKError.transitioning(currentState: state, validStates: [ .starting, .available, .unavailable(cause: nil) ])
        default:
            state = .unavailable(cause: cause)
        }
    }

    private func handleStopEvent(event: Event) throws {
        switch state {
        case .initialized:
            throw BKError.transitioning(currentState: state, validStates: [ .starting, .available, .unavailable(cause: nil) ])
        default:
            state = .initialized
        }
    }

}
