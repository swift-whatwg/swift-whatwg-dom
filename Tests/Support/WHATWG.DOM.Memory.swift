public import WHATWG_DOM

extension WHATWG.DOM {

    public final class Memory {

        public final class Element {
            public var name: String
            public var data: String
            public var attributes: [(name: String, value: String)]
            public var value: String
            public var checked: Bool
            public var children: [Element]
            public weak var parent: Element?
            public var listeners: [(event: String, listener: Int32)]

            init(name: String, data: String = "") {
                self.name = name
                self.data = data
                self.attributes = []
                self.value = ""
                self.checked = false
                self.children = []
                self.listeners = []
            }
        }

        public let root: Element

        public var nodes: [Int32: Element]

        public var rules: [String]

        public var flushes: Int

        public var operations: Int

        public var scheduled: Int

        public var target: WHATWG.DOM.Target

        public init(root name: String = "main") {
            self.root = Element(name: name)
            self.nodes = [:]
            self.rules = []
            self.flushes = 0
            self.operations = 0
            self.scheduled = 0
            self.target = WHATWG.DOM.Target()
        }
    }
}

extension WHATWG.DOM.Memory {

    public var host: WHATWG.DOM.Host {
        WHATWG.DOM.Host(
            flush: { self.apply($0) },
            schedule: { self.scheduled += 1 },
            target: { self.target }
        )
    }

    public var html: String { root.children.map(Self.html).joined() }

    public static func html(_ element: Element) -> String {
        if element.name == "#text" { return element.data }
        var attributes = element.attributes.map { " \($0.name)=\"\($0.value)\"" }.joined()
        if element.checked { attributes += " :checked" }
        if !element.value.isEmpty { attributes += " :value=\"\(element.value)\"" }
        return "<\(element.name)\(attributes)>\(element.children.map(html).joined())</\(element.name)>"
    }

    public func fire(_ event: String, on element: Element, target: WHATWG.DOM.Target = WHATWG.DOM.Target()) {
        self.target = target
        for listener in element.listeners where listener.event == event {
            WHATWG.DOM.Loop.dispatch(listener.listener)
        }
    }

    public func first(_ name: String, in element: Element? = nil) -> Element? {
        let start = element ?? root
        for child in start.children {
            if child.name == name { return child }
            if let found = first(name, in: child) { return found }
        }
        return nil
    }

    public func apply(_ bytes: [UInt8]) {
        flushes += 1
        var at = 0
        func int() -> Int32 {
            let value = UInt32(bytes[at]) | UInt32(bytes[at + 1]) << 8 | UInt32(bytes[at + 2]) << 16 | UInt32(bytes[at + 3]) << 24
            at += 4
            return Int32(bitPattern: value)
        }
        func string() -> String {
            let count = Int(int())
            defer { at += count }
            return String(decoding: bytes[at..<(at + count)], as: UTF8.self)
        }
        while at < bytes.count {
            operations += 1
            guard let operation = WHATWG.DOM.Operation(rawValue: bytes[at]) else { fatalError("unknown operation") }
            at += 1
            switch operation {
            case .element: let id = int(); nodes[id] = Element(name: string())
            case .text: let id = int(); nodes[id] = Element(name: "#text", data: string())
            case .select: let id = int(); _ = string(); nodes[id] = root
            case .insert:
                let parent = nodes[int()]!
                let child = nodes[int()]!
                let before = int()
                if let old = child.parent { old.children.removeAll { $0 === child } }
                if before > 0, let anchor = nodes[before], let index = parent.children.firstIndex(where: { $0 === anchor }) {
                    parent.children.insert(child, at: index)
                } else {
                    parent.children.append(child)
                }
                child.parent = parent
            case .remove:
                let id = int()
                if let node = nodes[id], let parent = node.parent { parent.children.removeAll { $0 === node } }
                nodes[id] = nil
            case .release: nodes[int()] = nil
            case .attribute:
                let node = nodes[int()]!
                let name = string()
                let value = string()
                if let index = node.attributes.firstIndex(where: { $0.name == name }) {
                    node.attributes[index].value = value
                } else {
                    node.attributes.append((name, value))
                }
            case .unset:
                let node = nodes[int()]!
                let name = string()
                node.attributes.removeAll { $0.name == name }
            case .value: let node = nodes[int()]!; node.value = string()
            case .checked: let node = nodes[int()]!; node.checked = bytes[at] != 0; at += 1
            case .data: let node = nodes[int()]!; node.data = string()
            case .listen:
                let node = nodes[int()]!
                let event = string()
                node.listeners.append((event, int()))
            case .ignore:
                let node = nodes[int()]!
                let event = string()
                let listener = int()
                node.listeners.removeAll { $0.event == event && $0.listener == listener }
            case .clear: let node = nodes[int()]!; node.children.removeAll()
            case .style: rules.append(string())
            }
        }
    }
}
