public import WHATWG_DOM

extension WHATWG.DOM {

    public final class Memory {

        public let root: WHATWG.DOM.Memory.Element

        public var nodes: [Int32: WHATWG.DOM.Memory.Element]

        public var rules: [String]

        public var flushes: Int

        public var operations: Int

        public var scheduled: Int

        public var target: WHATWG.DOM.Target

        public init(root name: String = "main") {
            self.root = WHATWG.DOM.Memory.Element(name: name)
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

    public var html: String {
        root.children.map(\.html).joined()
    }

    public func fire(
        _ event: WHATWG.DOM.Event,
        on element: WHATWG.DOM.Memory.Element,
        target: WHATWG.DOM.Target = WHATWG.DOM.Target()
    ) {
        self.target = target
        for listener in element.listeners where listener.event == event.type {
            unsafe WHATWG.DOM.Loop.dispatch(listener.listener)
        }
    }

    public func first(_ name: String) -> WHATWG.DOM.Memory.Element {
        root.first(name) ?? WHATWG.DOM.Memory.Element(name: "#missing")
    }

    func node(_ id: Int32) -> WHATWG.DOM.Memory.Element {
        nodes[id] ?? WHATWG.DOM.Memory.Element(name: "#missing")
    }

    public func apply(_ bytes: [Byte]) {
        flushes += 1
        var reader = WHATWG.DOM.Memory.Reader(bytes)
        while let operation = reader.operation() {
            operations += 1
            apply(operation, &reader)
        }
    }

    func apply(_ operation: WHATWG.DOM.Operation, _ reader: inout WHATWG.DOM.Memory.Reader) {
        switch operation {
        case .element:
            let id = reader.int()
            nodes[id] = WHATWG.DOM.Memory.Element(name: reader.string())

        case .text:
            let id = reader.int()
            nodes[id] = WHATWG.DOM.Memory.Element(name: "#text", data: reader.string())

        case .select:
            let id = reader.int()
            _ = reader.string()
            nodes[id] = root

        case .insert:
            let parent = node(reader.int())
            let child = node(reader.int())
            let before = reader.int()
            parent.insert(child, before: before > 0 ? nodes[before] : nil)

        case .remove:
            let id = reader.int()
            node(id).detach()
            nodes[id] = nil

        case .release:
            nodes[reader.int()] = nil

        case .attribute:
            let element = node(reader.int())
            let name = reader.string()
            element.set(name, reader.string())

        case .unset:
            let element = node(reader.int())
            let name = reader.string()
            element.attributes.removeAll { $0.name == name }

        case .value:
            let element = node(reader.int())
            element.value = reader.string()

        case .checked:
            let element = node(reader.int())
            element.checkedness = reader.byte() == Byte(bitPattern: 1) ? .checked : .unchecked

        case .data:
            let element = node(reader.int())
            element.data = reader.string()

        case .listen:
            let element = node(reader.int())
            let event = reader.string()
            element.listeners.append((event, reader.int()))

        case .ignore:
            let element = node(reader.int())
            let event = reader.string()
            let listener = reader.int()
            element.listeners.removeAll { $0.event == event && $0.listener == listener }

        case .clear:
            node(reader.int()).children.removeAll()

        case .style:
            rules.append(reader.string())
        }
    }
}
