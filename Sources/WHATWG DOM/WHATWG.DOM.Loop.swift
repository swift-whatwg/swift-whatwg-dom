extension WHATWG.DOM {

    public enum Loop {

        nonisolated(unsafe) public static var dispatch: (Int32) -> Void = { _ in }

        nonisolated(unsafe) public static var tick: () -> Void = {}
    }
}
