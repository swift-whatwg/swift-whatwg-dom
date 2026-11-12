import Testing
import WHATWG_DOM

enum `WHATWG.DOM.Event Tests` {}

extension `WHATWG.DOM.Event Tests` {
    @Suite
    struct `An event is its type by name` {
        @Test
        func `a named event has the type the standard gives it`() {
            #expect(WHATWG.DOM.Event.click.type == "click")
            #expect(WHATWG.DOM.Event.input.type == "input")
            #expect(WHATWG.DOM.Event.change.type == "change")
            #expect(WHATWG.DOM.Event.submit.type == "submit")
            #expect(WHATWG.DOM.Event.focus.type == "focus")
            #expect(WHATWG.DOM.Event.blur.type == "blur")
            #expect(WHATWG.DOM.Event.keydown.type == "keydown")
            #expect(WHATWG.DOM.Event.keyup.type == "keyup")
            #expect(WHATWG.DOM.Event.pointerdown.type == "pointerdown")
            #expect(WHATWG.DOM.Event.pointerup.type == "pointerup")
        }

        @Test
        func `an event made from the same type is the same event`() {
            #expect(WHATWG.DOM.Event("click") == .click)
            #expect(WHATWG.DOM.Event("Click") != .click)
        }

        @Test
        func `any other type is an event too`() {
            #expect(WHATWG.DOM.Event("transitionend").type == "transitionend")
        }
    }
}
