internal final class StateBox<Value> {
    private weak var graph: Graph?
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
            if graph == nil {
                graph = Graph.current
            }

            // Remove lazy values whose nodes have been deallocated
            dependencies = dependencies.filter { $0.value != nil }
            if let node = graph!.activeNodeStack.last, dependencies.contains(where: { $0.value === node }) == false {
                dependencies.append(Weak(node))
            }
            return _value
        }
        set {
            if graph == nil {
                graph = Graph.current
            }
            _value = newValue
            for d in dependencies {
                d.value?.setNeedsRebuild()
            }
        }
    }
}
