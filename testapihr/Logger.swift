//
//  Logger.swift
//  testapihr
//
//  Created by Tek on 2023/1/8.
//

import Foundation

internal protocol LoggerDelegate: AnyObject {
    func loggerDidLogString(_ string: String)
}

internal struct Logger {

    // MARK: Properties

    internal static weak var delegate: LoggerDelegate?

    internal static let loggingDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    // MARK: Functions

    internal static func log(_ string: String) {
        let date = Date()
        let stringWithDate = "[\(loggingDateFormatter.string(from: date))] \(string)"
        print(stringWithDate, terminator: "")
        Logger.delegate?.loggerDidLogString(stringWithDate)
    }

}
