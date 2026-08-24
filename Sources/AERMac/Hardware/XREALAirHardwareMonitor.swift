#if os(macOS)
import Foundation
import IOKit.hid
import AERCore

struct XREALHIDDeviceSnapshot: Equatable, Sendable {
    var vendorID: Int
    var productID: Int
    var productName: String?
    var transport: String?
    var interfaceNumber: Int?
}

/// Read-only Air 1 HID discovery boundary.
///
/// No MCU writes or firmware operations exist here. Until physical hardware is
/// available, discovery is intentionally conservative: match the known VID/PID,
/// poll for attach/detach, and expose snapshots for logging/calibration work.
final class XREALAirHardwareMonitor {
    private let manager: IOHIDManager
    private var pollTimer: Timer?
    private(set) var devices: [XREALHIDDeviceSnapshot] = []
    var onDevicesChanged: (([XREALHIDDeviceSnapshot]) -> Void)?

    init() {
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let matching: [String: Any] = [
            kIOHIDVendorIDKey as String: Int(XREALDeviceDescriptor.air1.vendorID),
            kIOHIDProductIDKey as String: Int(XREALDeviceDescriptor.air1.productID)
        ]
        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    deinit {
        stopPolling()
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func startPolling(interval: TimeInterval = 1.0) {
        guard pollTimer == nil else { return }
        refresh()
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    func refresh() {
        let next = snapshots()
        guard next != devices else { return }
        devices = next
        onDevicesChanged?(next)
    }

    private func snapshots() -> [XREALHIDDeviceSnapshot] {
        guard let set = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> else { return [] }
        return set.map { device in
            XREALHIDDeviceSnapshot(
                vendorID: intProperty(device, key: kIOHIDVendorIDKey as CFString) ?? 0,
                productID: intProperty(device, key: kIOHIDProductIDKey as CFString) ?? 0,
                productName: stringProperty(device, key: kIOHIDProductKey as CFString),
                transport: stringProperty(device, key: kIOHIDTransportKey as CFString),
                interfaceNumber: intProperty(device, key: "InterfaceNumber" as CFString)
            )
        }
        .sorted { ($0.interfaceNumber ?? -1) < ($1.interfaceNumber ?? -1) }
    }

    private func intProperty(_ device: IOHIDDevice, key: CFString) -> Int? {
        (IOHIDDeviceGetProperty(device, key) as? NSNumber)?.intValue
    }

    private func stringProperty(_ device: IOHIDDevice, key: CFString) -> String? {
        IOHIDDeviceGetProperty(device, key) as? String
    }
}

struct XREALRawHIDPacket: Codable, Sendable {
    var timestamp: Double
    var interfaceNumber: Int?
    var reportID: UInt8
    var bytes: [UInt8]
}

/// JSON-lines sink ready for the real HID report callback on arrival day.
/// Captures are ignored by git by default.
final class XREALRawPacketLogger {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func append(interfaceNumber: Int?, reportID: UInt8, bytes: UnsafeBufferPointer<UInt8>) throws {
        let packet = XREALRawHIDPacket(
            timestamp: ProcessInfo.processInfo.systemUptime,
            interfaceNumber: interfaceNumber,
            reportID: reportID,
            bytes: Array(bytes)
        )
        var data = try JSONEncoder().encode(packet)
        data.append(0x0A)

        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
    }
}
#endif
