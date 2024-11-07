internal final class Weak<A: AnyObject> {
    internal weak var value: A?
    internal init(_ value: A) {
        self.value = value
    }
}
