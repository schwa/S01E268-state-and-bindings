public final class Weak<A: AnyObject> {
    weak var value: A?
    init(_ value: A) {
        self.value = value
    }
}
