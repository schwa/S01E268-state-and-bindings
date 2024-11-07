internal final class StateBox<Value> {
    private var _value: Value
    private var dependencies: [Weak<Node>] = []
    var binding: Binding<Value> = Binding(
        get: { fatalError("Empty Binding: get() called.") },
        set: { _ in fatalError("Empty Binding: set() called.") }
    )

    init(_ value: Value) {
        self._value = value
        self.binding = Binding(get: { [unowned self] in
            self.value
        }, set: { [unowned self] in
            self.value = $0
        })
    }

    var value: Value {
        get {
            currentBodies.withLockUnchecked { currentBodies in
                // Remove lazy values whose nodes have been deallocated
                dependencies = dependencies.filter { $0.value != nil }
                if let node = currentBodies.last, dependencies.contains(where: { $0.value === node }) == false {
                    dependencies.append(Weak(node))
                }
                return _value
            }
        }
        set {
            _value = newValue
            for d in dependencies {
                d.value?.setNeedsRebuild()
            }
        }
    }
}
