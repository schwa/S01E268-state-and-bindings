internal protocol StateProperty {
    var value: Any { get nonmutating set }
}

@propertyWrapper
public struct State<Value>: StateProperty {
    private var box: Box<StateBox<Value>>

    public init(wrappedValue: Value) {
        box = Box(StateBox(wrappedValue))
    }

    public var wrappedValue: Value {
        get { box.value.value }
        nonmutating set { box.value.value = newValue }
    }

    public var projectedValue: Binding<Value> {
        box.value.binding
    }

    var value: Any {
        get { box.value }
        nonmutating set {
            guard let newBox = newValue as? StateBox<Value> else {
                fatalError("Expected StateBox<Value> in State.value set")
            }
            box.value = newBox
        }
    }
}
