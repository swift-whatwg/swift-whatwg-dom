# swift-whatwg-dom

Use this package when you need the names the WHATWG DOM Living Standard gives to things a page reports: `WHATWG.DOM.Event` is an event's type by name, and `WHATWG.DOM.Checkedness` is whether a checkbox or radio button is checked. It holds no bridge to a browser. Code that changes a page's DOM from WebAssembly is swift-html's `HTML DOM`.

## Laws

- An event is its type string, compared exactly: `WHATWG.DOM.Event("click")` equals `.click`, and `"Click"` is another event.
- The named events (`click`, `input`, `change`, `submit`, `focus`, `blur`, `keydown`, `keyup`, `pointerdown`, `pointerup`) are constants, not a closed set. Any other type is written `WHATWG.DOM.Event("name")`.
- Checkedness has two values, `checked` and `unchecked`. An indeterminate checkbox is still one of the two.
- The module builds as Embedded Swift.
