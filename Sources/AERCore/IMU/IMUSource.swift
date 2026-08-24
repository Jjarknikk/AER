import Foundation

public protocol IMUSource: AnyObject {
    var displayName: String { get }
    var isRunning: Bool { get }
    func start(_ onSample: @escaping (IMUSample) -> Void) throws
    func stop()
}

public enum IMUSourceError: Error, Equatable {
    case alreadyRunning
    case unavailable(String)
}
