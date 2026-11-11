public import WHATWG_DOM

extension WHATWG.DOM.Memory {

    public struct Reader {

        let bytes: [Byte]

        var at: Int

        public init(_ bytes: [Byte]) {
            self.bytes = bytes
            self.at = 0
        }
    }
}

extension WHATWG.DOM.Memory.Reader {

    public mutating func byte() -> Byte {
        defer { at += 1 }
        return bytes[at]
    }

    public mutating func operation() -> WHATWG.DOM.Operation? {
        guard at < bytes.count else { return nil }
        return WHATWG.DOM.Operation(byte())
    }

    public mutating func int() -> Int32 {
        var bits: UInt32 = 0
        for shift in [0, 8, 16, 24] {
            bits |= UInt32(UInt8(bitPattern: byte())) << UInt32(shift)
        }
        return Int32(bitPattern: bits)
    }

    public mutating func string() -> String {
        let count = Int(int())
        defer { at += count }
        return String(decoding: bytes[at..<(at + count)].map { UInt8(bitPattern: $0) }, as: UTF8.self)
    }
}
