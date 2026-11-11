#if arch(wasm32)
    extension WHATWG.DOM.Host {

        public static var browser: Self {
            Self(
                flush: { bytes in
                    unsafe bytes.withUnsafeBytes { buffer in
                        unsafe _flush(buffer.baseAddress, Int32(buffer.count))
                    }
                },
                schedule: { _schedule() },
                target: {
                    let count = unsafe _value(nil, 0)
                    var units = [UInt8](repeating: 0, count: Int(count))
                    unsafe units.withUnsafeMutableBytes { buffer in
                        _ = unsafe _value(buffer.baseAddress, count)
                    }
                    return WHATWG.DOM.Target(
                        value: String(decoding: units, as: UTF8.self),
                        checkedness: _checked() != 0 ? .checked : .unchecked
                    )
                }
            )
        }
    }

    @_extern(wasm, module: "whatwg_dom", name: "flush")
    private func _flush(_ pointer: UnsafeRawPointer?, _ count: Int32)

    @_extern(wasm, module: "whatwg_dom", name: "schedule")
    private func _schedule()

    @_extern(wasm, module: "whatwg_dom", name: "value")
    private func _value(_ pointer: UnsafeMutableRawPointer?, _ capacity: Int32) -> Int32

    @_extern(wasm, module: "whatwg_dom", name: "checked")
    private func _checked() -> Int32

    @_expose(wasm, "whatwg_dom_dispatch")
    public func _dispatch(_ listener: Int32) {
        unsafe WHATWG.DOM.Loop.dispatch(listener)
    }

    @_expose(wasm, "whatwg_dom_tick")
    public func _tick() {
        unsafe WHATWG.DOM.Loop.tick()
    }
#endif
