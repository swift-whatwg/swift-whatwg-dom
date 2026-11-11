extension WHATWG.DOM {

    public struct Host {

        public var flush: ([Byte]) -> Void

        public var schedule: () -> Void

        public var target: () -> WHATWG.DOM.Target

        public init(
            flush: @escaping ([Byte]) -> Void,
            schedule: @escaping () -> Void,
            target: @escaping () -> WHATWG.DOM.Target
        ) {
            self.flush = flush
            self.schedule = schedule
            self.target = target
        }
    }
}
