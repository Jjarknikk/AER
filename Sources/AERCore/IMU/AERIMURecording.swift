import Foundation

public enum AERIMUTimestampSource: String, Codable, Sendable {
    case monotonicHost
    case deviceClock
    case replay
    case synthetic
    case unknown
}

public struct AERIMUDeviceMetadata: Codable, Equatable, Sendable {
    public var model: String?
    public var vendorID: UInt16?
    public var productID: UInt16?
    public var firmwareVersion: String?

    public init(
        model: String? = nil,
        vendorID: UInt16? = nil,
        productID: UInt16? = nil,
        firmwareVersion: String? = nil
    ) {
        self.model = model
        self.vendorID = vendorID
        self.productID = productID
        self.firmwareVersion = firmwareVersion
    }

    public static let air1 = AERIMUDeviceMetadata(
        model: "XREAL Air / Nreal Air (NR-7100RGL)",
        vendorID: XREALDeviceDescriptor.air1.vendorID,
        productID: XREALDeviceDescriptor.air1.productID
    )
}

public struct AERIMUMeasurementUnits: Codable, Equatable, Sendable {
    public var gyroscope: String
    public var accelerometer: String

    public init(gyroscope: String, accelerometer: String) {
        self.gyroscope = gyroscope
        self.accelerometer = accelerometer
    }

    public static let normalizedSI = AERIMUMeasurementUnits(
        gyroscope: "radians_per_second",
        accelerometer: "g"
    )

    public static let deviceNative = AERIMUMeasurementUnits(
        gyroscope: "device_native",
        accelerometer: "device_native"
    )
}

public struct AERIMUAxisTransform: Codable, Equatable, Sendable {
    /// Row-major 3x3 matrix mapping source axes into AER's calibrated axes.
    public var matrix3x3: [Double]

    public init(matrix3x3: [Double]) {
        self.matrix3x3 = matrix3x3
    }

    public var isValid: Bool { matrix3x3.count == 9 }

    public static let identity = AERIMUAxisTransform(matrix3x3: [
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ])
}

public struct AERIMUHeader: Codable, Equatable, Sendable {
    public var createdAtUTC: String?
    public var device: AERIMUDeviceMetadata?
    public var units: AERIMUMeasurementUnits
    public var timestampSource: AERIMUTimestampSource
    public var calibrationTransform: AERIMUAxisTransform
    public var notes: String?

    public init(
        createdAtUTC: String? = nil,
        device: AERIMUDeviceMetadata? = nil,
        units: AERIMUMeasurementUnits = .normalizedSI,
        timestampSource: AERIMUTimestampSource = .monotonicHost,
        calibrationTransform: AERIMUAxisTransform = .identity,
        notes: String? = nil
    ) {
        self.createdAtUTC = createdAtUTC
        self.device = device
        self.units = units
        self.timestampSource = timestampSource
        self.calibrationTransform = calibrationTransform
        self.notes = notes
    }
}

/// Portable capture format for raw/normalized IMU sessions.
///
/// `.aerimu` remains human-readable JSON while the protocol evolves. Version 2
/// adds explicit device, unit, timestamp and calibration metadata. The optional
/// header preserves decoding compatibility with the original v1 recordings.
public struct AERIMURecording: Codable, Equatable, Sendable {
    public static let currentFormatVersion = 2

    public var formatVersion: Int
    public var source: String
    public var nominalSampleRateHz: Double?
    public var header: AERIMUHeader?
    public var samples: [IMUSample]

    public init(
        formatVersion: Int = AERIMURecording.currentFormatVersion,
        source: String,
        nominalSampleRateHz: Double? = nil,
        header: AERIMUHeader? = AERIMUHeader(),
        samples: [IMUSample]
    ) {
        self.formatVersion = formatVersion
        self.source = source
        self.nominalSampleRateHz = nominalSampleRateHz
        self.header = header
        self.samples = samples
    }

    public func encoded(prettyPrinted: Bool = true) throws -> Data {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        }
        return try encoder.encode(self)
    }

    public static func decode(_ data: Data) throws -> AERIMURecording {
        try JSONDecoder().decode(AERIMURecording.self, from: data)
    }

    public func write(to url: URL, prettyPrinted: Bool = true) throws {
        try encoded(prettyPrinted: prettyPrinted).write(to: url, options: .atomic)
    }

    public static func read(from url: URL) throws -> AERIMURecording {
        try decode(Data(contentsOf: url))
    }
}
