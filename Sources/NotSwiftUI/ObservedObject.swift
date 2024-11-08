import Combine

internal protocol AnyObservedObject {
    @MainActor
    func addDependency(_ node: Node)
}

// MARK: -

@propertyWrapper
public struct ObservedObject<ObjectType: ObservableObject> {
    private var box: ObservedObjectBox<ObjectType>

    public init(wrappedValue: ObjectType) {
        box = ObservedObjectBox(wrappedValue)
    }

    public var wrappedValue: ObjectType {
        box.object
    }

    public var projectedValue: ProjectedValue<ObjectType> {
        .init(self)
    }
}

extension ObservedObject: Equatable {
    public static func == (l: ObservedObject, r: ObservedObject) -> Bool {
        l.wrappedValue === r.wrappedValue
    }
}

extension ObservedObject: AnyObservedObject {
    func addDependency(_ node: Node) {
        box.addDependency(node)
    }
}

// MARK: -

fileprivate final class ObservedObjectBox<ObjectType: ObservableObject> {
    fileprivate let object: ObjectType
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

// MARK: -

@dynamicMemberLookup
public struct ProjectedValue <ObjectType: ObservableObject> {
    private var observedObject: ObservedObject<ObjectType>

    fileprivate init(_ observedObject: ObservedObject<ObjectType>) {
        self.observedObject = observedObject
    }

    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Value>) -> Binding<Value> {
        Binding(get: {
            observedObject.wrappedValue[keyPath: keyPath]
        }, set: {
            observedObject.wrappedValue[keyPath: keyPath] = $0
        })
    }
}
