import Foundation

public struct XREALDeviceDescriptor: Equatable, Sendable {
    public var name: String
    public var vendorID: UInt16
    public var productID: UInt16
    public var imuInterface: Int
    public var mcuInterface: Int

    public init(name: String, vendorID: UInt16, productID: UInt16, imuInterface: Int, mcuInterface: Int) {
        self.name = name
        self.vendorID = vendorID
        self.productID = productID
        self.imuInterface = imuInterface
        self.mcuInterface = mcuInterface
    }

    // Values verified against the MIT-licensed xrealair-sdk-macos HID table.
    public static let air1 = XREALDeviceDescriptor(
        name: "XREAL Air / Nreal Air",
        vendorID: 0x3318,
        productID: 0x0424,
        imuInterface: 3,
        mcuInterface: 4
    )

    public static let air2 = XREALDeviceDescriptor(
        name: "XREAL Air 2",
        vendorID: 0x3318,
        productID: 0x0428,
        imuInterface: 3,
        mcuInterface: 4
    )
}
