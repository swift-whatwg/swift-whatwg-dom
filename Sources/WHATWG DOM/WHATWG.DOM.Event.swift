extension WHATWG.DOM {

    public struct Event: Hashable, Sendable {

        public let type: String

        public init(_ type: String) {
            self.type = type
        }
    }
}

extension WHATWG.DOM.Event {
    public static let click = Self("click")
    public static let input = Self("input")
    public static let change = Self("change")
    public static let submit = Self("submit")
    public static let focus = Self("focus")
    public static let blur = Self("blur")
    public static let keydown = Self("keydown")
    public static let keyup = Self("keyup")
    public static let pointerdown = Self("pointerdown")
    public static let pointerup = Self("pointerup")
}
