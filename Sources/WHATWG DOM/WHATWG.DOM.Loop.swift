extension WHATWG.DOM {

    public enum Loop {}
}

extension WHATWG.DOM.Loop {

    // WHY: a WebAssembly module in a page runs on the page's one thread; the exported functions and the module's own code are its only callers.
    nonisolated(unsafe) public static var dispatch: (Int32) -> Void = { _ in }

    // WHY: a WebAssembly module in a page runs on the page's one thread; the exported functions and the module's own code are its only callers.
    nonisolated(unsafe) public static var tick: () -> Void = {}
}
