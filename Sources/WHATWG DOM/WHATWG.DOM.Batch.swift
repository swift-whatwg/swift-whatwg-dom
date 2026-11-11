extension WHATWG.DOM {

    public struct Batch: Sendable {

        public private(set) var bytes: [Byte]

        private var next: Int32

        private var free: [Int32]

        public init() {
            self.bytes = []
            self.next = 1
            self.free = []
        }
    }
}

extension WHATWG.DOM.Batch {

    public var isEmpty: Bool { bytes.isEmpty }

    public mutating func drain() -> [Byte] {
        defer { bytes.removeAll(keepingCapacity: true) }
        return bytes
    }

    private mutating func allocate() -> WHATWG.DOM.Node {
        if let id = free.popLast() { return WHATWG.DOM.Node(id) }
        defer { next += 1 }
        return WHATWG.DOM.Node(next)
    }

    private mutating func write(_ operation: WHATWG.DOM.Operation) {
        bytes.append(Byte(operation))
    }

    private mutating func write(_ value: Int32) {
        let bits = UInt32(bitPattern: value)
        bytes.append(Byte(bitPattern: UInt8(truncatingIfNeeded: bits)))
        bytes.append(Byte(bitPattern: UInt8(truncatingIfNeeded: bits >> 8)))
        bytes.append(Byte(bitPattern: UInt8(truncatingIfNeeded: bits >> 16)))
        bytes.append(Byte(bitPattern: UInt8(truncatingIfNeeded: bits >> 24)))
    }

    private mutating func write(_ node: WHATWG.DOM.Node) {
        write(node.id)
    }

    private mutating func write(_ string: String) {
        write(Int32(string.utf8.count))
        for unit in string.utf8 {
            bytes.append(Byte(bitPattern: unit))
        }
    }
}

extension WHATWG.DOM.Batch {

    public mutating func element(_ name: String) -> WHATWG.DOM.Node {
        let node = allocate()
        write(.element)
        write(node)
        write(name)
        return node
    }

    public mutating func text(_ data: String) -> WHATWG.DOM.Node {
        let node = allocate()
        write(.text)
        write(node)
        write(data)
        return node
    }

    public mutating func select(_ selector: String) -> WHATWG.DOM.Node {
        let node = allocate()
        write(.select)
        write(node)
        write(selector)
        return node
    }

    public mutating func insert(_ child: WHATWG.DOM.Node, into parent: WHATWG.DOM.Node, before: WHATWG.DOM.Node?) {
        write(.insert)
        write(parent)
        write(child)
        write(before?.id ?? 0)
    }

    public mutating func remove(_ node: WHATWG.DOM.Node) {
        write(.remove)
        write(node)
        free.append(node.id)
    }

    public mutating func release(_ node: WHATWG.DOM.Node) {
        write(.release)
        write(node)
        free.append(node.id)
    }

    public mutating func attribute(_ name: String, _ value: String?, on node: WHATWG.DOM.Node) {
        if let value {
            write(.attribute)
            write(node)
            write(name)
            write(value)
        } else {
            write(.unset)
            write(node)
            write(name)
        }
    }

    public mutating func value(_ value: String, on node: WHATWG.DOM.Node) {
        write(.value)
        write(node)
        write(value)
    }

    public mutating func checked(_ checkedness: WHATWG.DOM.Checkedness, on node: WHATWG.DOM.Node) {
        write(.checked)
        write(node)
        bytes.append(Byte(bitPattern: checkedness == .checked ? 1 : 0))
    }

    public mutating func data(_ data: String, on node: WHATWG.DOM.Node) {
        write(.data)
        write(node)
        write(data)
    }

    public mutating func listen(_ event: String, _ listener: Int32, on node: WHATWG.DOM.Node) {
        write(.listen)
        write(node)
        write(event)
        write(listener)
    }

    public mutating func ignore(_ event: String, _ listener: Int32, on node: WHATWG.DOM.Node) {
        write(.ignore)
        write(node)
        write(event)
        write(listener)
    }

    public mutating func clear(_ node: WHATWG.DOM.Node) {
        write(.clear)
        write(node)
    }

    public mutating func style(_ rule: String) {
        write(.style)
        write(rule)
    }
}
