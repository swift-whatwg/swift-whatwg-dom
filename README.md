# swift-whatwg-dom

Use this package when Swift compiled to WebAssembly has to change a browser page's DOM. Start from `WHATWG.DOM.Batch`: it records DOM changes (create an element or a text node, insert, remove, set an attribute, a property or text, listen for an event, add a style rule) as one command buffer, and `WHATWG.DOM.Host.flush` hands that buffer to the page in a single call. Events come back through `WHATWG.DOM.Loop.dispatch`. `WHATWG.DOM.Script.source` is the JavaScript that applies a buffer and starts the module; a server can serve it inline. `WHATWG.DOM.Memory`, in the `WHATWG DOM Test Support` product, applies the same buffers to an in-memory tree for tests.

## Laws

- Node handles are allocated in Swift, so no DOM call returns a value across the boundary. A removed or released handle is reused.
- A buffer is applied in the order it was written. `insert` with no anchor appends; with an anchor it inserts before it.
- `attribute(_:_:on:)` with `nil` removes the attribute.
- `value` and `checked` set the element's properties, not its attributes. The script leaves `value` alone when it already equals the new value, so a caret does not jump.
- A `submit` listener prevents the browser's default submission.
- The module builds as Embedded Swift for `wasm32-unknown-wasip1`. `WHATWG.DOM.Host.browser` and the exported functions `whatwg_dom_dispatch` and `whatwg_dom_tick` exist only there.
