internal import os

protocol StateProperty {
    var value: Any { get nonmutating set }
}

@propertyWrapper
public struct State<Value>: StateProperty {
    private var box: Box<StateBox<Value>>

    public init(wrappedValue: Value) {
        self.box = Box(StateBox(wrappedValue))
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
        nonmutating set { box.value = newValue as! StateBox<Value> }
    }
}

let currentBodies = OSAllocatedUnfairLock<[Node]>(uncheckedState: [])

//var currentBodies: [Node] = []

final class StateBox<Value> {
    private var _value: Value
    private var dependencies: [Weak<Node>] = []
    var binding: Binding<Value> = Binding(get: { fatalError() }, set: { _ in fatalError() })

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
                if let node = currentBodies.last {
                    dependencies.append(Weak(node))
                }
                // skip duplicates and remove nil entries?
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
