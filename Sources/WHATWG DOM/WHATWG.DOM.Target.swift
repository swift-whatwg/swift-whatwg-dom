extension WHATWG.DOM {

    public struct Target: Sendable {

        public var value: String

        public var checkedness: WHATWG.DOM.Checkedness

        public init(value: String = "", checkedness: WHATWG.DOM.Checkedness = .unchecked) {
            self.value = value
            self.checkedness = checkedness
        }
    }
}
