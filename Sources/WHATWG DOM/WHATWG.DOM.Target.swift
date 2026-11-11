extension WHATWG.DOM {

    public struct Target: Sendable {

        public var value: String

        public var checked: Bool

        public init(value: String = "", checked: Bool = false) {
            self.value = value
            self.checked = checked
        }
    }
}
