import Foundation

/// Portable capture format for raw/normalized IMU sessions.
///
/// Real Air recordings will be stored as `.aerimu` JSON while the protocol is
/// still evolving. Keeping the format human-readable makes calibration work
/// easier before we eventually consider a binary transport.
public struct AERIMURecording: Codable, Equatable, Sendable {
    public static let currentFormatVersion = 1

    public var formatVersion: Int
    public var source: String
    public var nominalSampleRateHz: Double?
    public var samples: [IMUSample]

    public init(
        formatVersion: Int = AERIMURecording.currentFormatVersion,
        source: String,
        nominalSampleRateHz: Double? = nil,
        samples: [IMUSample]
    ) {
        self.formatVersion = formatVersion
        self.source = source
        self.nominalSampleRateHz = nominalSampleRateHz
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
