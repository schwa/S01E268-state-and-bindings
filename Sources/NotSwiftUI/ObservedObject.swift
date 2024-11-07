import Combine

internal protocol AnyObservedObject {
    @MainActor
    func addDependency(_ node: Node)
}

@propertyWrapper
public struct ObservedObject<ObjectType: ObservableObject>: AnyObservedObject {
    private var box: ObservedObjectBox<ObjectType>

    @dynamicMemberLookup
    public struct Wrapper {
        private var observedObject: ObservedObject<ObjectType>
        fileprivate init(_ o: ObservedObject<ObjectType>) {
            observedObject = o
        }

        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Value>) -> Binding<Value> {
            Binding(get: {
                observedObject.wrappedValue[keyPath: keyPath]
            }, set: {
                observedObject.wrappedValue[keyPath: keyPath] = $0
            })
        }
    }

    public init(wrappedValue: ObjectType) {
        box = ObservedObjectBox(wrappedValue)
    }

    public var wrappedValue: ObjectType {
        box.object
    }

    public var projectedValue: Self.Wrapper {
        Wrapper(self)
    }

    func addDependency(_ node: Node) {
        box.addDependency(node)
    }
}

extension ObservedObject: Equatable {
    public static func == (l: ObservedObject, r: ObservedObject) -> Bool {
        l.wrappedValue === r.wrappedValue
    }
}

fileprivate final class ObservedObjectBox<ObjectType: ObservableObject> {
    fileprivate var object: ObjectType
    private var cancellable: AnyCancellable?
    private weak var node: Node?

    init(_ object: ObjectType) {
        self.object = object
    }

    @MainActor
    func addDependency(_ node: Node) {
        if node === self.node { return }
        self.node = node
        cancellable = object.objectWillChange.sink { _ in
            node.setNeedsRebuild()
        }
    }
}
