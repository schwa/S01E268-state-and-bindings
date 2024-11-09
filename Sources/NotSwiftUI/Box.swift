/// Contain a value with-in a reference type.
internal final class Box<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}
