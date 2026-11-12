import Testing
import WHATWG_DOM

enum `WHATWG.DOM.Checkedness Tests` {}

extension `WHATWG.DOM.Checkedness Tests` {
    @Suite
    struct `Checkedness has two values` {
        @Test
        func `checked and unchecked differ`() {
            #expect(WHATWG.DOM.Checkedness.checked != .unchecked)
            #expect(WHATWG.DOM.Checkedness.checked == .checked)
        }
    }
}
