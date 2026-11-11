extension WHATWG.DOM {

    public enum Operation: UInt8, Sendable, CaseIterable {
        case element = 1
        case text = 2
        case select = 3
        case insert = 4
        case remove = 5
        case release = 6
        case attribute = 7
        case unset = 8
        case value = 9
        case checked = 10
        case data = 11
        case listen = 12
        case ignore = 13
        case clear = 14
        case style = 15
    }
}
